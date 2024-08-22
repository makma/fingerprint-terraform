// DISTRIBUTION MODULE
variable "aliases" {
  type        = list(string)
}

variable "certificate_arn" {
  type        = string
  description = "Arn of the certificate"
}

// DNS MODULE
variable "subdomain_name" {
  type        = string
  description = "Subdomain name to be used in the CNAME"
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

// PROXY INTEGRATION MODULE
variable "fpjs_proxy_secret" {
  type = string
}

variable "download_path" {
  type = string
}

variable "result_path" {
  type = string
}
