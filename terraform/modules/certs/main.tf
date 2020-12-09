# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "certs_security_group" {
  name        = "${var.show_short_name}_certs_service_sg"
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
}

resource "aws_iam_role" "certs_role" {
  name = "${var.show_short_name}-certs-role"

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
      scattered = "role"
  }
}

resource "aws_iam_instance_profile" "certs_profile" {
  name = "${var.show_short_name}-certs-profile"
  role = aws_iam_role.certs_role.name
}

resource "aws_iam_role_policy" "certs_policy" {
  name = "${var.show_short_name}-certs-policy"
  role = aws_iam_role.certs_role.id

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

data "aws_ami" "ubuntu_ami" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/*ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "template_file" "init" {
  template = file("${path.module}/get-certs.sh")

  vars = {
    show_short_name = var.show_short_name
    show_domain_name = var.show_domain_name
    lets_encrypt_email = var.lets_encrypt_email
  }
}

resource "aws_spot_instance_request" "certs_service" {
  instance_type = var.instance_size
  wait_for_fulfillment = true

  # Lookup the correct AMI based on the region
  # we specified
  ami = data.aws_ami.ubuntu_ami.image_id

  availability_zone = "us-east-1b"

  iam_instance_profile = aws_iam_instance_profile.certs_profile.name

  # The name of our SSH keypair we created above.
  key_name = var.ssh_key_pair

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = [aws_security_group.certs_security_group.id]

  tags = {
    PromenadeShow = var.show_short_name
    PromenadeResourceType = "cert_fetcher"
  }
}

resource "cloudflare_record" "janus" {
  zone_id = var.cloudflare_zone_id
  name    = "janus.${var.show_domain_name}"
  type    = "A"
  ttl     = "60"
  value   = aws_spot_instance_request.certs_service.public_ip
  proxied = false
}

resource "cloudflare_record" "show" {
  zone_id = var.cloudflare_zone_id
  name    = "services.${var.show_domain_name}"
  type    = "A"
  ttl     = "60"
  value   = aws_spot_instance_request.certs_service.public_ip
  proxied = false
}

resource "cloudflare_record" "mongo" {
  zone_id = var.cloudflare_zone_id
  name    = "mongo.${var.show_domain_name}"
  type    = "A"
  ttl     = "60"
  value   = aws_spot_instance_request.certs_service.public_ip
  proxied = false
}

resource "cloudflare_record" "janus_numbered" {
  count = 10
  zone_id = var.cloudflare_zone_id
  name    = "janus${count.index}.${var.show_domain_name}"
  type    = "A"
  ttl     = "60"
  value   = aws_spot_instance_request.certs_service.public_ip
  proxied = false
}

resource "null_resource" "cert_script" {
  depends_on = [
    cloudflare_record.janus,
    cloudflare_record.show,
    cloudflare_record.mongo,
    cloudflare_record.janus_numbered
  ]
  connection {
    type = "ssh"
    user = "ubuntu"
    host = aws_spot_instance_request.certs_service.public_ip
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [data.template_file.init.rendered]
  }
}