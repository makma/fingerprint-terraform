variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token to communicate via Cloudflare provider"
  sensitive   = true
}

variable "account_id" {
  description = "Cloudflare Account ID"
  type        = string
}

variable "zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

variable "worker_name" {
  description = "Name of the Cloudflare Worker"
  type        = string
}

variable "worker_path" {
  description = "Path to the Worker script"
  type        = string
}

variable "agent_script_download_path" {
  description = "Value for AGENT_SCRIPT_DOWNLOAD_PATH"
  type        = string
}

variable "get_result_path" {
  description = "Value for GET_RESULT_PATH"
  type        = string
}

variable "proxy_secret" {
  description = "Value for PROXY_SECRET"
  type        = string
}

variable "worker_path_env" {
  description = "Value for WORKER_PATH"
  type        = string
}

variable "subdomain" {
  description = "Integration subdodmain"
  type        = string
}