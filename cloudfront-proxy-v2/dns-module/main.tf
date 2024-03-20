terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_record" "cname_record" {
  zone_id = var.cloudflare_zone_id
  name    = var.subdomain_name
  value   = var.distribution_domain
  type    = "CNAME"
  comment = "Fingerprint CloudFront v2 proxy integration via Terraform"
  ttl     = 3600
}
