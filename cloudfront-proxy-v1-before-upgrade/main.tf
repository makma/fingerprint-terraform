provider "aws" {
  region = var.selected_region
}

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "aws_cloudformation_stack" "fingerprint_proxy_stack-via-terraform-upgrading" {
  name = var.distribution_name

  parameters = {
    SecretName   = var.secret_name
    SecretRegion = var.secret_region
  }

 template_url = var.cloudformation_template_url

  // CAPABILITY_AUTO_EXPAND is required for the above CF template to execute successfully.
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_AUTO_EXPAND", "CAPABILITY_NAMED_IAM"]
}

resource "aws_cloudfront_distribution" "fingerprint-cloudfront-integration-v1-via-terraform" {

  enabled = true
  comment = "Fingerprint CloudFront Integration v1 created via Terraform"

  aliases = var.aliases

  origin {
    domain_name = "fpcdn.io"
    origin_id   = "fpcdn.io"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "FPJS_SECRET_NAME"
      value = var.secret_name
    }

    custom_header {
      name  = "FPJS_SECRET_REGION"
      value = var.secret_region
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "fpcdn.io"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    path_pattern           = var.behavior_path_pattern
    target_origin_id       = "fpcdn.io"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]

    cache_policy_id          = aws_cloudformation_stack.fingerprint_proxy_stack-via-terraform-upgrading.outputs["CachePolicyName"]
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" // All_viewer - https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-origin-request-policies.html

    # lambda_function_association {
    #   event_type   = "origin-request"
    #   lambda_arn   = format("%s%s:1", "arn:aws:lambda:us-east-1:912961505495:function:", aws_cloudformation_stack.fingerprint_proxy_stack-via-terraform-upgrading.outputs["LambdaFunctionName"])
    #   include_body = true
    # }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# Add a CNAME recortd to point to the created CloudFront distribution, use your name server provider instead
resource "cloudflare_record" "cname_record" {
  zone_id = var.cloudflare_zone_id
  name    = var.subdomain_name
  value   = aws_cloudfront_distribution.fingerprint-cloudfront-integration-v1-via-terraform.domain_name
  type    = "CNAME"
  comment = "Fingerprint CloudFront proxy integration via Terraform upgrading"
  ttl     = 3600
}
