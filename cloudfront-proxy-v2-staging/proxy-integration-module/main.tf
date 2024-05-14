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

resource "aws_cloudformation_stack" "fingerprint_cloudfront_v2_proxy_stack_staging_via_terraform" {
  name = var.distribution_name

  parameters = {
    ACMCertificateARN     = var.certificate_arn
    DistributionId        = var.distribution_id
    DomainNames           = var.aliases
    FpjsAgentDownloadPath = var.agent_download_path
    FpjsGetResultPath     = var.result_path
    FpjsPreSharedSecret   = var.proxy_secret
  }

  template_url = "https://fingerprint-pro-cloudfront-integration.s3.amazonaws.com/v2/template.yml"

  capabilities = ["CAPABILITY_IAM", "CAPABILITY_AUTO_EXPAND", "CAPABILITY_NAMED_IAM"]
}
