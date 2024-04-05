terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}


data "aws_secretsmanager_secret_version" "existing_secret" {
  secret_id = var.secrets_id
}

locals {
  endpoint_overrides = {
    FPJS_CDN_URL           = var.fpjs_cdn_url_override
    FPJS_INGRESS_BASE_HOST = var.fpjs_ingress_base_host_override
  }
}

resource "aws_secretsmanager_secret_version" "endpoints_overrides" {
  secret_id = var.secrets_id
  secret_string = jsonencode(merge(
    jsondecode(data.aws_secretsmanager_secret_version.existing_secret.secret_string), # Preserve existing secrets that are not managed by terraform
    local.endpoint_overrides
  ))
}
