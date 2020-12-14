# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "mongo_security_group" {
  name        = "${var.show_short_name}_mongo_service_sg"
  description = "Used in the terraform"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Mongo access from anywhere
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    PromenadeShow = var.show_short_name
    PromenadeResourceType = "mongo_sg"
  }
}

resource "aws_iam_role" "mongo_role" {
  name = "${var.show_short_name}-mongo-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    PromenadeShow = var.show_short_name
    PromenadeResourceType = "mongo_role"
  }
}

resource "aws_iam_instance_profile" "mongo_profile" {
  name = "${var.show_short_name}-mongo-profile"
  role = aws_iam_role.mongo_role.name
}

resource "aws_iam_role_policy" "mongo_policy" {
  name = "${var.show_short_name}-mongo-policy"
  role = aws_iam_role.mongo_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
          "arn:aws:s3:::${var.secrets_bucket_name}",
          "arn:aws:s3:::${var.secrets_bucket_name}/*"
      ]
    }
  ]
}
EOF
}

data "aws_ami" "mongo_ami" {
  owners = ["self"]

  filter {
    name   = "name"
    values = ["${var.show_short_name}-mongo-${var.arch}"]
  }
}

resource "aws_s3_bucket_object" "mongo_username" {
  bucket = var.secrets_bucket_name
  key    = "service-secrets/mongo-user"
  content = var.mongo_user

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = md5(var.mongo_user)
}

resource "aws_s3_bucket_object" "mongo_password" {
  bucket = var.secrets_bucket_name
  key    = "service-secrets/mongo-password"
  content = var.mongo_password

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = md5(var.mongo_password)
}

data "aws_ebs_volume" "mongo_volume" {
  most_recent = true

  filter {
    name   = "tag:PromenadeShow"
    values = [var.show_short_name]
  }

  filter {
    name   = "tag:PromenadeResourceType"
    values = ["mongo_volume"]
  }
}

resource "aws_spot_instance_request" "mongo_service" {
  count = var.use_spot ? 1 : 0
  instance_type = (var.arch == "arm64") ? "t4g.micro" : "t3a.micro" 
  wait_for_fulfillment = true

  # Lookup the correct AMI based on the region
  # we specified
  ami = data.aws_ami.mongo_ami.image_id

  availability_zone = data.aws_ebs_volume.mongo_volume.availability_zone

  iam_instance_profile = aws_iam_instance_profile.mongo_profile.name

  # The name of our SSH keypair we created above.
  key_name = var.ssh_key_pair

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = [aws_security_group.mongo_security_group.id]
  user_data = file("${path.module}/mount-volume.sh")

  tags = {
    PromenadeShow = var.show_short_name
    PromenadeResourceType = "mongo_vm"
  }
}

resource "aws_instance" "mongo_service" {
  count = var.use_spot ? 0 : 1
  instance_type = (var.arch == "arm64") ? "t4g.micro" : "t3a.micro" 

  # Lookup the correct AMI based on the region
  # we specified
  ami = data.aws_ami.mongo_ami.image_id

  availability_zone = data.aws_ebs_volume.mongo_volume.availability_zone

  iam_instance_profile = aws_iam_instance_profile.mongo_profile.name

  # The name of our SSH keypair we created above.
  key_name = var.ssh_key_pair

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = [aws_security_group.mongo_security_group.id]
  user_data = file("${path.module}/mount-volume.sh")

  tags = {
    PromenadeShow = var.show_short_name
    PromenadeResourceType = "mongo_vm"
  }
}

resource "aws_volume_attachment" "mongo_att" {
  device_name = "/dev/sdf"
  volume_id   = data.aws_ebs_volume.mongo_volume.id
  instance_id = var.use_spot ? aws_spot_instance_request.mongo_service[0].spot_instance_id : aws_instance.mongo_service[0].id
}

resource "cloudflare_record" "mongo_service" {
  zone_id = var.cloudflare_zone_id
  name    = "mongo.${var.show_domain_name}"
  type    = "A"
  ttl     = "60"
  value   = var.use_spot ? aws_spot_instance_request.mongo_service[0].public_ip : aws_instance.mongo_service[0].public_ip
  proxied = false
}