variable "selected_region" {
  type    = string
}

variable "secret_region" {
  type    = string
}

variable "secret_name" {
  type    = string
}

variable "distribution_name" {
  type    = string
}

variable "cloudformation_template_url" {
  type    = string
}

variable "aliases" {
  type    = list(string)
}

variable "certificate_arn" {
  type    = string
}

variable "behavior_path_pattern" {
  type    = string
}

variable "cloudflare_zone_id" {
  type    = string
}

variable "subdomain_name" {
  type    = string
  default = "cloudfront-v1-terraform"
}

variable "cloudflare_api_token" {
  type    = string
}