variable "group_name" {
  type = string
}

variable "product_id" {
  type = string
  default = "prd_Site_Accel"
}

variable "domain" {
  type = string
}

variable "origin" {
  type = string
}

variable "is_secure" {
  type = string
  default = "false" // string: true | false
}

variable "contact_email" {
  type = string
}

variable "rule_format" {
  type = string
  default = "latest"
}

variable "fpjs_proxy_secret" {
  type = string
  sensitive = true
}
