variable "region" {
  type        = string
  description = "The AWS region"
}

variable "secrets_id" {
  type        = string
  description = "Identifier of the secret where are env variables for hte integraiton stored"
}

variable "fpjs_cdn_url_override" {
  type        = string
  description = "CDN URL override"
}

variable "fpjs_ingress_base_host_override" {
  type        = string
  description = "Ingress API override"
}
