
module "proxy-integration-module" {
  source = "./proxy-integration-module"

  region              = var.selected_region
  distribution_id     = var.distribution_id
  aliases             = var.aliases
  proxy_secret        = var.proxy_secret
  agent_download_path = var.agent_download_path
  result_path         = var.result_path
  certificate_arn     = var.certificate_arn
}

data "aws_cloudfront_distribution" "created_distribution" {
  id = module.proxy-integration-module.cloudfront_distribution_id
}

module "dns-module" {
  source = "./dns-module"

  cloudflare_zone_id   = var.cloudflare_zone_id
  cloudflare_api_token = var.cloudflare_api_token
  subdomain_name       = var.subdomain_name
  distribution_domain  = data.aws_cloudfront_distribution.created_distribution.domain_name
}
