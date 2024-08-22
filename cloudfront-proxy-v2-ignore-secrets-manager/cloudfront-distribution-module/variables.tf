variable "aliases" {
  type        = list(string)
  description = "Domain aliases used for the distribution, sepparated by the plus sign +"
}

variable "certificate_arn" {
  type        = string
  description = "Arn of the certificate"
}


variable "fpjs_cache_policy_id" {
  type        = string
}

variable "fpjs_proxy_lambda_arn" {
  type        = string
}

variable "fpjs_agent_download_path" {
  type        = string
}

variable "fpjs_get_result_path" {
  type        = string
}

variable "fpjs_shared_secret" {
  type        = string
}