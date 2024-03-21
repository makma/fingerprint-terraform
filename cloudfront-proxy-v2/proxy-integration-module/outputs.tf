output "cache_policy_name" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack-via-terraform.outputs["CachePolicyName"]
}

output "cloudfront_distribution_id" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack-via-terraform.outputs["CloudFrontDistributionId"]
}

output "fingerprint_integration_settings_secret" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack-via-terraform.outputs["FingerprintIntegrationSettingsSecret"]
}

output "fingerprint_pro_mgmt_lambda" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack-via-terraform.outputs["FingerprintProMgmtLambda"]
}

output "is_cloudfront_distribution_created_by_deployment" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack-via-terraform.outputs["IsCloudFrontDistributionCreatedByDeployment"]
}

output "lambda_function_name" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack-via-terraform.outputs["LambdaFunctionName"]
}

output "lambda_function_version" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack-via-terraform.outputs["LambdaFunctionVersion"]
}

output "mgmt_lambda_function_url" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack-via-terraform.outputs["MgmtLambdaFunctionUrl"]
}

output "mgmt_settings_secret" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack-via-terraform.outputs["MgmtSettingsSecret"]
}