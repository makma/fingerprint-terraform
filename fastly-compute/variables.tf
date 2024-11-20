variable "service_name" {
  type        = string
  description = "Name of the Fastly Compute service"
}

variable "domain_name" {
  type        = string
  description = "Domain name for the service"
}

// The Fastly Terraform provider does not provide a means to seed the Secret Store with secrets (this is because the values are persisted into the Terraform state file as plaintext). To populate the Secret Store with secrets please use the Fastly API directly or the Fastly CLI.
variable "proxy_secret" {
  type        = string
  description = "Secret used for proxy authentication"
  sensitive   = true
}

variable "fastly_api_key" {
  type        = string
  description = "Fastly API key for authentication"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region for Fingerprint API (empty for global, eu for Europe, ap for Asia)"
  default     = ""  # defaults to global
  
  validation {
    condition     = contains(["", "eu", "ap"], var.region)
    error_message = "Region must be empty (for global), eu, or ap"
  }
}

variable "agent_script_download_path" {
  description = "Random path for agent script download to avoid ad blockers"
  type        = string
}

variable "get_result_path" {
  description = "Random path for identification results to avoid ad blockers"
  type        = string
} 