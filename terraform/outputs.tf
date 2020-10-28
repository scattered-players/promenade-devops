output "mongo_connection_string" {
  value = local.mongo_connection_string
}

output "jwt_secret" {
  value = random_password.jwt_secret.result
}

output "janus_api_secret" {
  value = random_password.janus_api_key.result
}

output "show_domain_name" {
  value = var.show_domain_name
}

output "show_short_name" {
  value = var.show_short_name
}