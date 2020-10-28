resource "aws_s3_bucket" "secrets" {
  bucket = "${var.show_short_name}-secret"
  acl    = "private"
  force_destroy = true
}

locals  {
  # show_bucket_name = "${var.show_short_name}-cdn"
  show_bucket_name = var.show_domain_name
}

resource "aws_s3_bucket" "show_site_bucket" {
  bucket = local.show_bucket_name
  policy =  templatefile("${path.module}/bucket-policy.json", { show_domain_name = local.show_bucket_name })
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "cloudflare_record" "show_domain_record" {
  zone_id  = var.cloudflare_zone_id
  name    = var.show_domain_name
  value   = aws_s3_bucket.show_site_bucket.website_endpoint
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_page_rule" "html_noncache_rule" {
  zone_id = var.cloudflare_zone_id
  target = "${var.show_domain_name}/*.html"
  priority = 1

  actions {
    cache_level = "bypass"
  }
}

resource "cloudflare_page_rule" "media_permacache_rule" {
  zone_id = var.cloudflare_zone_id
  target = "${var.show_domain_name}/media/*"
  priority = 2

  actions {
    cache_level = "cache_everything"
  }
}