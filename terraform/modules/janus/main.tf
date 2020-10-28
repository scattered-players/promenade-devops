resource "aws_s3_bucket_object" "janus_config" {
  for_each      = fileset("${path.module}/janus-conf/", "**/*.*")
  bucket        = var.secrets_bucket_name
  key           = "/janus-conf/${each.value}"
  content       = templatefile("${path.module}/janus-conf/${each.value}", {
    show_domain_name = var.show_domain_name
    janus_api_key = var.janus_api_key
  })
  etag          = md5(templatefile("${path.module}/janus-conf/${each.value}", {
    show_domain_name = var.show_domain_name
    janus_api_key = var.janus_api_key
  }))
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "janus_security_group" {
  name        = "janus_service_sg"
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

  # HTTPS access from anywhere
  ingress {
    from_port   = 8000
    to_port     = 40000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 8000
    to_port     = 40000
    protocol    = "udp"
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
    PromenadeResourceType = "janus_sg"
  }
}

resource "aws_iam_role" "janus_role" {
  name = "${var.show_short_name}-janus-role"

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
    PromenadeResourceType = "janus_role"
  }
}

resource "aws_iam_instance_profile" "janus_profile" {
  name = "${var.show_short_name}-janus-profile"
  role = aws_iam_role.janus_role.name
}

resource "aws_iam_role_policy" "janus_policy" {
  name = "${var.show_short_name}-janus-policy"
  role = aws_iam_role.janus_role.id

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

data "aws_ami" "janus_ami" {
  owners = ["self"]

  filter {
    name   = "name"
    values = ["${var.show_short_name}-janus-x86"]
  }
}

resource "aws_spot_instance_request" "janus_service" {

  depends_on = [
    aws_s3_bucket_object.janus_config
  ]
  count = var.server_count

  # spot_price    = "0.03"
  instance_type = "t3.micro"
  wait_for_fulfillment = true

  # Lookup the correct AMI based on the region
  # we specified
  ami = data.aws_ami.janus_ami.image_id

  availability_zone = "us-east-1b"

  iam_instance_profile = aws_iam_instance_profile.janus_profile.name

  # The name of our SSH keypair we created above.
  key_name = var.ssh_key_pair

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = [aws_security_group.janus_security_group.id]

  tags = {
    PromenadeShow = var.show_short_name
    PromenadeResourceType = "janus_vm"
  }
}

resource "cloudflare_record" "janus" {
  zone_id = var.cloudflare_zone_id
  name    = "janus.${var.show_domain_name}"
  type    = "A"
  ttl     = "60"
  value   = aws_spot_instance_request.janus_service[0].public_ip
  proxied = false
}

resource "cloudflare_record" "janus_numbered" {
  count = var.server_count
  zone_id = var.cloudflare_zone_id
  name    = "janus${count.index}.${var.show_domain_name}"
  type    = "A"
  ttl     = "60"
  value   = aws_spot_instance_request.janus_service[count.index].public_ip
  proxied = false
}