variable "fastly_api_token" {
  description = "Fastly API token for authentication"
  type        = string
  sensitive   = true
}

variable "integration_domain" {
  description = "Domain for the Fastly integration"
  type        = string
}

variable "integration_path" {
  description = "Path for the integration endpoint"
  type        = string
}

variable "agent_script_download_path" {
  description = "Path for downloading the agent script"
  type        = string
}

variable "get_result_path" {
  description = "Path for getting results"
  type        = string
}

variable "main_host" {
  description = "Main host domain"
  type        = string
}

variable "proxy_secret" {
  description = "Secret key for proxy authentication"
  type        = string
  sensitive   = true
} 

variable "integration_name" {
  description = "Name of the integration"
  type        = string
}