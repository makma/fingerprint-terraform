variable "region" {
  type        = string
  description = "The AWS region"
}

variable "distribution_id" {
  type        = string
  description = "The distribution where the integration would be attache to. If empty, the new distribution will be created"
}

variable "distribution_name" {
  type        = string
  description = "Name of the CloudFront Distribution if the new distribution is provisioned"
  default     = "FingerprintProCloudfrontIntegrationv2ViaTerraform"
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
}

variable "proxy_secret" {
  type        = string
  description = "Proxy secret generated in the Fingerprint Portal"
  sensitive   = true
}
