terraform {
  required_version = ">=1.5"
}

module "fingerprint_fastly_vcl_integration" {
  source                     = "github.com/fingerprintjs/terraform-fastly-fingerprint-vcl-proxy-integration"
  fastly_api_token           = var.fastly_api_token
  integration_domain         = var.integration_domain
  integration_path           = var.integration_path
  agent_script_download_path = var.agent_script_download_path
  get_result_path            = var.get_result_path
  main_host                  = var.main_host
  proxy_secret               = var.proxy_secret
  integration_name           = var.integration_name
}