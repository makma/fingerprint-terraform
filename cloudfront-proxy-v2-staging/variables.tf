variable "distribution_id" {
  type        = string
  description = "The distribution where the integration would be attache to. If empty, the new distribution will be created"
}

variable "selected_region" {
  type        = string
  description = "Region where the integration will be running"
  default     = "us-east-1"
}

variable "distribution_name" {
  type        = string
  description = "Name of the CloudFront Distribution if the new distribution is provisioned"
  default     = "FingerprintProCloudfrontIntegrationv2StagingViaTerraform"
}

variable "certificate_arn" {
  type        = string
  description = "Arn of the certificate"
}

variable "aliases" {
  type        = string
  description = "Domain aliases used for the distribution, sepparated by the plus sign +"
}

variable "agent_download_path" {
  type        = string
  description = "Agent download path"
}

variable "result_path" {
  type        = string
  description = "Get result path"
  default     = "result-path"
}

variable "proxy_secret" {
  type        = string
  description = "Proxy secret generated in the Fingerprint Portal"
  sensitive   = true
}

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

variable "fpjs_cdn_url_override" {
  type        = string
  description = "CDN URL override"
}

variable "fpjs_ingress_base_host_override" {
  type        = string
  description = "Ingress API override"
}