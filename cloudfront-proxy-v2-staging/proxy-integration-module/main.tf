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
    FpjsBehaviorPath      = var.behavior_path
    FpjsGetResultPath     = var.result_path
    FpjsPreSharedSecret   = var.proxy_secret
  }

  template_url = "https://fingerprint-pro-cloudfront-integration-lambda-function.s3.amazonaws.com/releaseV2/template.yml"

  capabilities = ["CAPABILITY_IAM", "CAPABILITY_AUTO_EXPAND", "CAPABILITY_NAMED_IAM"]
}
