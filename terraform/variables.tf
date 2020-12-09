variable "aws_region" {
  description = "AWS region to launch servers."
}

variable "ssh_public_key" {
  description = "The public key you'll use to access the resources"
}

variable "show_short_name" {
  description = "The name of the show."
}

variable "show_domain_name" {
  description = "The domain name for your show."
}

variable "cloudflare_api_key" {
  description = "API Key from Cloudflare"
}

variable "lets_encrypt_email" {
  description = "Email address to use with LetsEncrypt"
}

variable "eventbrite_api_key" {
}

variable "eventbrite_series_id" {
}

variable "janus_server_count" {
  default = 6
}

variable "run_cert_service" {
  type    = bool
  default = false
}

variable "run_mongo" {
  type    = bool
  default = false
}

variable "run_show" {
  type    = bool
  default = false
}

variable "run_janus" {
  type    = bool
  default = false
}

variable "should_format_volume" {
  type    = bool
  default = false
}

variable "instance_size" {
  default = "t4g.micro"
}