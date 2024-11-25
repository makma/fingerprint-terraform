variable "fastly_api_key" {
  type        = string
  description = "Fastly API key"
  sensitive   = true
}

variable "domain_name" {
  type        = string
  description = "Domain name for the Fastly service (e.g., metrics.yourwebsite.com)"
}

variable "origin_address" {
  type        = string
  description = "Origin address (e.g., metrics-origin.yourwebsite.com)"
}

variable "proxy_secret" {
  type        = string
  description = "Proxy secret from Fingerprint Dashboard"
  sensitive   = true
}

variable "integration_path" {
  type        = string
  description = "Random string for the integration path"
}

variable "agent_script_download_path" {
  type        = string
  description = "Random string for the agent script download path"
}

variable "get_result_path" {
  type        = string
  description = "Random string for the get result path"
} 