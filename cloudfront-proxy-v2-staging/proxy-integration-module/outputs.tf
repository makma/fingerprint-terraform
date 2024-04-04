output "cache_policy_name" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack_staging_via_terraform.outputs["CachePolicyName"]
}

output "cloudfront_distribution_id" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack_staging_via_terraform.outputs["CloudFrontDistributionId"]
}

output "fingerprint_integration_settings_secret" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack_staging_via_terraform.outputs["FingerprintIntegrationSettingsSecret"]
}

output "fingerprint_pro_mgmt_lambda" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack_staging_via_terraform.outputs["FingerprintProMgmtLambda"]
}

output "is_cloudfront_distribution_created_by_deployment" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack_staging_via_terraform.outputs["IsCloudFrontDistributionCreatedByDeployment"]
}

output "lambda_function_name" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack_staging_via_terraform.outputs["LambdaFunctionName"]
}

output "lambda_function_version" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack_staging_via_terraform.outputs["LambdaFunctionVersion"]
}

output "mgmt_lambda_function_url" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack_staging_via_terraform.outputs["MgmtLambdaFunctionUrl"]
}

output "mgmt_settings_secret" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack_staging_via_terraform.outputs["MgmtSettingsSecret"]
}