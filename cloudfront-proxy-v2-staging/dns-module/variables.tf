variable "subdomain_name" {
  type        = string
  description = "Subdomain name to be used in the CNAME"
}

variable "distribution_domain" {
  type        = string
  description = "Distribution domain to be used as a target in the CNAME"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare ZoneID"
}

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token to communicate via Cloudflare provider"
  sensitive   = true
}