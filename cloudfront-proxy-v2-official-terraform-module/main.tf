module "fingerprint_cloudfront_integration" {
  source = "fingerprintjs/fingerprint-cloudfront-proxy-integration/aws"
  version = "1.0.0"

  fpjs_agent_download_path = var.download_path
  fpjs_get_result_path = var.result_path
  fpjs_shared_secret = var.fpjs_proxy_secret
}


module "cloudfront-distribution-module" {
  source = "./cloudfront-distribution-module"

  aliases         = var.aliases
  certificate_arn = var.certificate_arn
  fpjs_secret_manager_arn = module.fingerprint_cloudfront_integration.fpjs_secret_manager_arn
  fpjs_cache_policy_id = module.fingerprint_cloudfront_integration.fpjs_cache_policy_id
  fpjs_proxy_lambda_arn = module.fingerprint_cloudfront_integration.fpjs_proxy_lambda_arn
}

data "aws_cloudfront_distribution" "created_distribution" {
  id = module.cloudfront-distribution-module.cloudfront_distribution_id
}

module "dns-module" {
  source = "./dns-module"

  cloudflare_zone_id   = var.cloudflare_zone_id
  cloudflare_api_token = var.cloudflare_api_token
  subdomain_name       = var.subdomain_name
  distribution_domain  = data.aws_cloudfront_distribution.created_distribution.domain_name
}
