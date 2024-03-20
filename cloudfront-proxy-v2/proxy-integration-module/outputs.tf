output "distribution_id" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack-via-terraform.outputs["CloudFrontDistributionId"]
}

output "mgmt_lambda_function_url" {
  value = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack-via-terraform.outputs["MgmtLambdaFunctionUrl"]
}