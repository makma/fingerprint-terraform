variable "service_name" {
  type        = string
  description = "Name of the Fastly Compute service"
}

variable "domain_name" {
  type        = string
  description = "Domain name for the service"
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

variable "open_client_response_plugins_enabled" {
  description = "Flag to enable/disable open client response plugins"
  type        = string
  default     = "false"
}

variable "save_to_kv_store_plugin_enabled" {
  description = "Flag to enable/disable save to KV store plugin"
  type        = string
  default     = "false"
}