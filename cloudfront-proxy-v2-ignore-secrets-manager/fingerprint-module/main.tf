terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.57.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.2"
    }
  }
}

resource "random_id" "integration_id" {
  byte_length = 6
}

locals {
  integration_id = random_id.integration_id.hex
}

# region cache policy

resource "aws_cloudfront_cache_policy" "fpjs_procdn" {
  name        = "FingerprintProCDNCachePolicy-${local.integration_id}"
  default_ttl = 180
  max_ttl     = 180
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "whitelist"
      query_strings {
        items = ["version", "loaderVersion"]
      }
    }

    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

# endregion

# region proxy lambda

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    sid    = "AllowAwsToAssumeRole"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "fpjs_proxy_lambda" {
  name                 = "fingerprint-pro-lambda-role-${local.integration_id}"
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns  = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

resource "aws_lambda_function" "fpjs_proxy_lambda" {
  description      = "Fingerprint Proxy Lambda@Edge function"
  filename         = "${path.module}/fingerprintjs-pro-cloudfront-lambda-function.js.zip"
  function_name    = "fingerprint-pro-cloudfront-lambda-${local.integration_id}"
  role             = aws_iam_role.fpjs_proxy_lambda.arn
  handler          = "fingerprintjs-pro-cloudfront-lambda-function.handler"
  source_code_hash = filebase64sha256("${path.module}/fingerprintjs-pro-cloudfront-lambda-function.js.zip")
  memory_size      = 128
  timeout          = 10

  runtime = "nodejs20.x"

  publish = true
}

# endregion