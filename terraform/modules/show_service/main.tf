data "template_file" "credentials" {
  template = file("${path.module}/credentials.json")

  vars = {
    show_domain_name = var.show_domain_name
    mongo_connection_string = var.mongo_connection_string
    janus_api_key = var.janus_api_key
    jwt_secret = var.jwt_secret
    eventbrite_api_key = var.eventbrite_api_key
    eventbrite_series_id = var.eventbrite_series_id
  }
}

resource "aws_s3_bucket_object" "show_credentials" {
  bucket = var.secrets_bucket_name
  key    = "service-secrets/credentials.json"
  content = data.template_file.credentials.rendered

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = md5(data.template_file.credentials.rendered)
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "show_security_group" {
  name        = "show_service_sg"
  description = "Used in the terraform"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
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
    PromenadeResourceType = "show_sg"
  }
}

resource "aws_iam_role" "show_role" {
  name = "${var.show_short_name}-show-role"

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
    PromenadeResourceType = "show_role"
  }
}

resource "aws_iam_instance_profile" "show_profile" {
  name = "${var.show_short_name}-show-profile"
  role = aws_iam_role.show_role.name
}

resource "aws_iam_role_policy" "show_policy" {
  name = "${var.show_short_name}-show-policy"
  role = aws_iam_role.show_role.id

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

data "aws_ami" "show_ami" {
  owners = ["self"]

  filter {
    name   = "name"
    values = ["${var.show_short_name}-show-x86"]
  }
}

resource "aws_spot_instance_request" "show_service" {
  instance_type = "t3.micro"
  wait_for_fulfillment = true

  # Lookup the correct AMI based on the region
  # we specified
  ami = data.aws_ami.show_ami.image_id

  availability_zone = "us-east-1b"

  iam_instance_profile = aws_iam_instance_profile.show_profile.name

  # The name of our SSH keypair we created above.
  key_name = var.ssh_key_pair

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = [aws_security_group.show_security_group.id]

  tags = {
    PromenadeShow = var.show_short_name
    PromenadeResourceType = "show_vm"
  }
}

resource "cloudflare_record" "show_service" {
  zone_id = var.cloudflare_zone_id
  name    = "services.${var.show_domain_name}"
  type    = "A"
  ttl     = "60"
  value   = aws_spot_instance_request.show_service.public_ip
  proxied = false
}