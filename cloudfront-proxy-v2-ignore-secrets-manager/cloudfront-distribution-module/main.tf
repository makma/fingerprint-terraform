locals {
  fpcdn_origin_id  = "fpcdn.io"
  fpjs_origin_name = "fpcdn.io"
}

resource "aws_cloudfront_distribution" "fpjs_cloudfront_distribution" {
  comment = "Fingerprint distribution (created via Terraform official Fingerprint module)"

  enabled      = true
  http_version = "http1.1"
  price_class  = "PriceClass_100"
  aliases      = var.aliases

  origin {
    domain_name = local.fpjs_origin_name
    origin_id   = local.fpcdn_origin_id
    custom_origin_config {
      origin_protocol_policy = "https-only"
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1.2"]
    }
    custom_header {
      name  = "fpjs_pre_shared_secret"
      value = var.fpjs_shared_secret
    }
    custom_header {
      name  = "fpjs_agent_download_path"
      value = var.fpjs_agent_download_path
    }
    custom_header {
      name  = "fpjs_get_result_path"
      value = var.fpjs_get_result_path
    }
  }

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = var.fpjs_cache_policy_id
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # Default AllViewer policy
    target_origin_id         = local.fpcdn_origin_id
    viewer_protocol_policy   = "https-only"
    compress                 = true

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = var.fpjs_proxy_lambda_arn
      include_body = true
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.certificate_arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
