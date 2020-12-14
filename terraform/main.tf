terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {
  email = "chris.uehlinger@gmail.com"
  api_token = var.cloudflare_api_key
}

resource "cloudflare_zone" "show_dns_zone" {
    zone = var.show_domain_name
}

resource "cloudflare_zone_settings_override" "show_cdn_settings" {
    zone_id = cloudflare_zone.show_dns_zone.id
    settings {
      ssl = "flexible"
    }
}

resource "aws_key_pair" "show_key_pair" {
  key_name   = "${var.show_short_name}-key"
  public_key = var.ssh_public_key
}

module "s3_resources" {
  source = "./modules/s3_resources"
  aws_region = var.aws_region
  show_short_name = var.show_short_name
  show_domain_name = var.show_domain_name
  cloudflare_zone_id = cloudflare_zone.show_dns_zone.id
}

resource "random_password" "janus_api_key" {
  length = 64
  special = false
}

resource "random_password" "jwt_secret" {
  length = 64
  special = false
}

data "template_file" "promenade_config" {
  template = file("${path.module}/promenade-config.json")

  vars = {
    show_short_name = var.show_short_name
    show_domain_name = var.show_domain_name
    janus_server_count = var.janus_server_count
  }
}

resource "aws_s3_bucket_object" "promenade_config" {
  bucket = module.s3_resources.secrets_bucket_name
  key    = "service-secrets/promenade-config.json"
  content = data.template_file.promenade_config.rendered

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = md5(data.template_file.promenade_config.rendered)
}

module "certs" {
  source = "./modules/certs"
  count = var.run_cert_service ? 1 : 0
  secrets_bucket_name = module.s3_resources.secrets_bucket_name
  show_short_name = var.show_short_name
  cloudflare_zone_id = cloudflare_zone.show_dns_zone.id
  show_domain_name = var.show_domain_name
  lets_encrypt_email = var.lets_encrypt_email
  ssh_key_pair = aws_key_pair.show_key_pair.key_name
  arch = var.arch
  use_spot = var.use_spot
}

resource "random_password" "mongo_password" {
  length = 32
  special = false
}

locals {
  mongo_user = "dbUser"
  mongo_connection_string = "mongodb://${local.mongo_user}:${random_password.mongo_password.result}@mongo.${var.show_domain_name}/${var.show_short_name}"
}

module "mongo" {
  source = "./modules/mongo"
  count = (var.run_show || var.run_mongo) ? 1 : 0
  secrets_bucket_name = module.s3_resources.secrets_bucket_name
  show_short_name = var.show_short_name
  cloudflare_zone_id = cloudflare_zone.show_dns_zone.id
  show_domain_name = var.show_domain_name
  mongo_user = local.mongo_user
  mongo_password = random_password.mongo_password.result
  ssh_key_pair = aws_key_pair.show_key_pair.key_name
  arch = var.arch
  use_spot = var.use_spot
}

module "show_service" {
  source = "./modules/show_service"
  depends_on = [
    module.mongo
  ]
  count = var.run_show ? 1 : 0
  secrets_bucket_name = module.s3_resources.secrets_bucket_name
  show_short_name = var.show_short_name
  cloudflare_zone_id = cloudflare_zone.show_dns_zone.id
  show_domain_name = var.show_domain_name
  mongo_connection_string = local.mongo_connection_string
  janus_api_key = random_password.janus_api_key.result
  jwt_secret = random_password.jwt_secret.result
  eventbrite_api_key = var.eventbrite_api_key
  eventbrite_series_id = var.eventbrite_series_id
  ssh_key_pair = aws_key_pair.show_key_pair.key_name
  arch = var.arch
  use_spot = var.use_spot
}

module "janus" {
  source = "./modules/janus"
  count = (var.run_show || var.run_janus) ? 1 : 0
  secrets_bucket_name = module.s3_resources.secrets_bucket_name
  show_short_name = var.show_short_name
  cloudflare_zone_id = cloudflare_zone.show_dns_zone.id
  show_domain_name = var.show_domain_name
  server_count = var.janus_server_count
  ssh_key_pair = aws_key_pair.show_key_pair.key_name
  janus_api_key = random_password.janus_api_key.result
  arch = var.arch
  use_spot = var.use_spot
}