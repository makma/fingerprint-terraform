variable "selected_region" {
  type    = string
  default = "us-east-1"
}

variable "distribution_name" {
  type    = string
  default = "FingerprintProCloudfrontIntegrationv2ViaTerraform"
}

variable "certificate_arn" {
  type    = string
  default = "arn:aws:acm:us-east-1:912961505495:certificate/dbee3e0c-94f8-450e-bdaa-3288ddb29d9e"
}

variable "aliases" {
  type    = string
  default = "cloudfront-v2-terraform.martinmakarsky.com"
}

variable "agent_download_path" {
  type    = string
  default = "download-path"
}

variable "behavior_path" {
  type    = string
  default = "behavior-path"
}

variable "result_path" {
  type    = string
  default = "result-path"
}

variable "proxy_secret" {
  type    = string
  default = ""
}

variable "cloudflare_zone_id" {
  type    = string
  default = "681ec2df3edaf4db245f2add56749078"
}

variable "subdomain_name" {
  type    = string
  default = "cloudfront-v2-terraform"
}

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
  api_token = "" # use your Cloudflare API token
}

resource "aws_cloudformation_stack" "fingerprint_cloudfront_v2_proxy_stack-via-terraform" {
  name = var.distribution_name

  parameters = {
    ACMCertificateARN     = var.certificate_arn
    DomainNames           = var.aliases
    FpjsAgentDownloadPath = var.agent_download_path
    FpjsBehaviorPath      = var.behavior_path
    FpjsGetResultPath     = var.result_path
    FpjsPreSharedSecret   = var.proxy_secret
  }
  
template_body = <<EOF
{
    "AWSTemplateFormatVersion": "2010-09-09",
    "Transform": [
        "AWS::Serverless-2016-10-31"
    ],
    "Description": "Fingerprint Pro Lambda@Edge function for CloudFront integration",
    "Parameters": {
        "DistributionId": {
            "Description": "CloudFront distribution ID. Leave it empty to create a new distribution",
            "Default": "",
            "Type": "String"
        },
        "FpjsBehaviorPath": {
            "AllowedPattern": "^([a-zA-Z0-9\\-])+$",
            "Description": "FPJS_BEHAVIOR_PATH value",
            "Type": "String"
        },
        "FpjsGetResultPath": {
            "AllowedPattern": "^([a-zA-Z0-9\\-])+$",
            "Description": "FPJS_GET_RESULT_PATH value",
            "Type": "String"
        },
        "FpjsAgentDownloadPath": {
            "AllowedPattern": "^([a-zA-Z0-9\\-])+$",
            "Description": "FPJS_AGENT_DOWNLOAD_PATH value",
            "Type": "String"
        },
        "FpjsPreSharedSecret": {
            "AllowedPattern": "^([a-zA-Z0-9\\-])+$",
            "Description": "FPJS_PRE_SHARED_SECRET value",
            "Type": "String",
            "NoEcho": true
        },
        "DomainNames": {
            "Description": "(Optional) Domain names to attach to CloudFront distribution. Several domains names should be separated by plus sign (domain1.com+domain2.com)",
            "Default": "",
            "Type": "String"
        },
        "ACMCertificateARN": {
            "Description": "(Optinal) ARN of SSL certificate in AWS Certificate Manager (the certificate could be requested in the AWS Certifucate Manager or uploaded from the third-party service to AWS).",
            "Default": "",
            "Type": "String"
        }
    },
    "Conditions": {
        "CreateCloudFrontDistribution": {
            "Fn::Equals": [
                {
                    "Ref": "DistributionId"
                },
                ""
            ]
        },
        "AttachDomainToCloudFront": {
            "Fn::And": [
                {
                    "Fn::Not": [
                        {
                            "Fn::Equals": [
                                {
                                    "Ref": "DomainNames"
                                },
                                ""
                            ]
                        }
                    ]
                },
                {
                    "Fn::Not": [
                        {
                            "Fn::Equals": [
                                {
                                    "Ref": "ACMCertificateARN"
                                },
                                ""
                            ]
                        }
                    ]
                }
            ]
        }
    },
    "Resources": {
        "FingerprintIntegrationSettingsSecret": {
            "Type": "AWS::SecretsManager::Secret",
            "Properties": {
                "Description": "AWS Secret with a custom Fingerprint integration settings",
                "Name": {
                    "Fn::Join": [
                        "-",
                        [
                            "fingerprint-pro-cloudfront-integration-settings-secret",
                            {
                                "Fn::Select": [
                                    4,
                                    {
                                        "Fn::Split": [
                                            "-",
                                            {
                                                "Fn::Select": [
                                                    2,
                                                    {
                                                        "Fn::Split": [
                                                            "/",
                                                            {
                                                                "Ref": "AWS::StackId"
                                                            }
                                                        ]
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    ]
                },
                "SecretString": {
                    "Fn::Join": [
                        "",
                        [
                            "{",
                            {
                                "Fn::Join": [
                                    ",",
                                    [
                                        {
                                            "Fn::Join": [
                                                ":",
                                                [
                                                    "\"fpjs_behavior_path\"",
                                                    {
                                                        "Fn::Sub": [
                                                            "\"$${value}\"",
                                                            {
                                                                "value": {
                                                                    "Ref": "FpjsBehaviorPath"
                                                                }
                                                            }
                                                        ]
                                                    }
                                                ]
                                            ]
                                        },
                                        {
                                            "Fn::Join": [
                                                ":",
                                                [
                                                    "\"fpjs_get_result_path\"",
                                                    {
                                                        "Fn::Sub": [
                                                            "\"$${value}\"",
                                                            {
                                                                "value": {
                                                                    "Ref": "FpjsGetResultPath"
                                                                }
                                                            }
                                                        ]
                                                    }
                                                ]
                                            ]
                                        },
                                        {
                                            "Fn::Join": [
                                                ":",
                                                [
                                                    "\"fpjs_agent_download_path\"",
                                                    {
                                                        "Fn::Sub": [
                                                            "\"$${value}\"",
                                                            {
                                                                "value": {
                                                                    "Ref": "FpjsAgentDownloadPath"
                                                                }
                                                            }
                                                        ]
                                                    }
                                                ]
                                            ]
                                        },
                                        {
                                            "Fn::Join": [
                                                ":",
                                                [
                                                    "\"fpjs_pre_shared_secret\"",
                                                    {
                                                        "Fn::Sub": [
                                                            "\"$${value}\"",
                                                            {
                                                                "value": {
                                                                    "Ref": "FpjsPreSharedSecret"
                                                                }
                                                            }
                                                        ]
                                                    }
                                                ]
                                            ]
                                        }
                                    ]
                                ]
                            },
                            "}"
                        ]
                    ]
                }
            }
        },
        "FpIntLambdaFunctionExecutionRole": {
            "Type": "AWS::IAM::Role",
            "DependsOn": [
                "FingerprintIntegrationSettingsSecret"
            ],
            "Metadata": {
                "SamResourceId": "FpIntLambdaFunctionExecutionRole"
            },
            "Properties": {
                "Description": "Lambda@Edge function execution role",
                "RoleName": {
                    "Fn::Join": [
                        "-",
                        [
                            "fingerprint-pro-lambda-role",
                            {
                                "Fn::Select": [
                                    4,
                                    {
                                        "Fn::Split": [
                                            "-",
                                            {
                                                "Fn::Select": [
                                                    2,
                                                    {
                                                        "Fn::Split": [
                                                            "/",
                                                            {
                                                                "Ref": "AWS::StackId"
                                                            }
                                                        ]
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    ]
                },
                "AssumeRolePolicyDocument": {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Effect": "Allow",
                            "Action": "sts:AssumeRole",
                            "Principal": {
                                "Service": [
                                    "lambda.amazonaws.com",
                                    "edgelambda.amazonaws.com"
                                ]
                            }
                        }
                    ]
                },
                "Policies": [
                    {
                        "PolicyName": "LambdaExecutionPolicy",
                        "PolicyDocument": {
                            "Version": "2012-10-17",
                            "Statement": [
                                {
                                    "Effect": "Allow",
                                    "Action": [
                                        "logs:CreateLogGroup",
                                        "logs:CreateLogStream",
                                        "logs:PutLogEvents"
                                    ],
                                    "Resource": "arn:aws:logs:*:*:*"
                                }
                            ]
                        }
                    },
                    {
                        "PolicyName": "AWSSecretAccess",
                        "PolicyDocument": {
                            "Version": "2012-10-17",
                            "Statement": [
                                {
                                    "Effect": "Allow",
                                    "Action": [
                                        "secretsmanager:GetSecretValue"
                                    ],
                                    "Resource": {
                                        "Ref": "FingerprintIntegrationSettingsSecret"
                                    }
                                }
                            ]
                        }
                    }
                ],
                "ManagedPolicyArns": [
                    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
                ]
            }
        },
        "FingerprintProCloudFrontLambda": {
            "Type": "AWS::Serverless::Function",
            "DependsOn": [
                "FpIntLambdaFunctionExecutionRole"
            ],
            "Properties": {
                "Description": "Lambda@Edge function definition",
                "FunctionName": {
                    "Fn::Join": [
                        "-",
                        [
                            "fingerprint-pro-cloudfront-lambda",
                            {
                                "Fn::Select": [
                                    4,
                                    {
                                        "Fn::Split": [
                                            "-",
                                            {
                                                "Fn::Select": [
                                                    2,
                                                    {
                                                        "Fn::Split": [
                                                            "/",
                                                            {
                                                                "Ref": "AWS::StackId"
                                                            }
                                                        ]
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    ]
                },
                "Handler": "fingerprintjs-pro-cloudfront-lambda-function.handler",
                "Runtime": "nodejs20.x",
                "CodeUri": "s3://fingerprint-pro-cloudfront-integration-lambda-function/releaseV2/lambda_latest.zip",
                "MemorySize": 128,
                "Timeout": 10,
                "Role": {
                    "Fn::GetAtt": [
                        "FpIntLambdaFunctionExecutionRole",
                        "Arn"
                    ]
                }
            }
        },
        "FingerprintProCloudFrontLambdaVersion": {
            "Type": "AWS::Lambda::Version",
            "DependsOn": [
                "FingerprintProCloudFrontLambda"
            ],
            "Properties": {
                "FunctionName": {
                    "Ref": "FingerprintProCloudFrontLambda"
                },
                "Description": "Lambda@Edge function's version reference (v1)"
            }
        },
        "FingerprintProCDNCachePolicy": {
            "Type": "AWS::CloudFront::CachePolicy",
            "Properties": {
                "CachePolicyConfig": {
                    "Name": {
                        "Fn::Join": [
                            "-",
                            [
                                "FingerprintProCDNCachePolicy",
                                {
                                    "Fn::Select": [
                                        4,
                                        {
                                            "Fn::Split": [
                                                "-",
                                                {
                                                    "Fn::Select": [
                                                        2,
                                                        {
                                                            "Fn::Split": [
                                                                "/",
                                                                {
                                                                    "Ref": "AWS::StackId"
                                                                }
                                                            ]
                                                        }
                                                    ]
                                                }
                                            ]
                                        }
                                    ]
                                }
                            ]
                        ]
                    },
                    "MinTTL": 0,
                    "MaxTTL": 180,
                    "DefaultTTL": 180,
                    "ParametersInCacheKeyAndForwardedToOrigin": {
                        "CookiesConfig": {
                            "CookieBehavior": "none"
                        },
                        "HeadersConfig": {
                            "HeaderBehavior": "none"
                        },
                        "QueryStringsConfig": {
                            "QueryStringBehavior": "whitelist",
                            "QueryStrings": [
                                "version",
                                "loaderVersion"
                            ]
                        },
                        "EnableAcceptEncodingBrotli": true,
                        "EnableAcceptEncodingGzip": true
                    }
                }
            }
        },
        "CloudFrontDistribution": {
            "Type": "AWS::CloudFront::Distribution",
            "Condition": "CreateCloudFrontDistribution",
            "Properties": {
                "DistributionConfig": {
                    "Aliases": {
                        "Fn::If": [
                            "AttachDomainToCloudFront",
                            {
                                "Fn::Split": [
                                    "+",
                                    {
                                        "Ref": "DomainNames"
                                    }
                                ]
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    "ViewerCertificate": {
                        "Fn::If": [
                            "AttachDomainToCloudFront",
                            {
                                "AcmCertificateArn": {
                                    "Ref": "ACMCertificateARN"
                                },
                                "MinimumProtocolVersion": "TLSv1.2_2018",
                                "SslSupportMethod": "sni-only"
                            },
                            {
                                "Ref": "AWS::NoValue"
                            }
                        ]
                    },
                    "DefaultCacheBehavior": {
                        "AllowedMethods": [
                            "HEAD",
                            "GET",
                            "POST",
                            "PUT",
                            "PATCH",
                            "DELETE",
                            "OPTIONS"
                        ],
                        "CachePolicyId": {
                            "Ref": "FingerprintProCDNCachePolicy"
                        },
                        "Compress": true,
                        "LambdaFunctionAssociations": [
                            {
                                "EventType": "origin-request",
                                "IncludeBody": true,
                                "LambdaFunctionARN": {
                                    "Ref": "FingerprintProCloudFrontLambdaVersion"
                                }
                            }
                        ],
                        "OriginRequestPolicyId": "216adef6-5c7f-47e4-b989-5492eafa07d3",
                        "SmoothStreaming": false,
                        "TargetOriginId": "fpcdn.io",
                        "ViewerProtocolPolicy": "https-only"
                    },
                    "Enabled": true,
                    "Origins": [
                        {
                            "Id": "fpcdn.io",
                            "DomainName": "fpcdn.io",
                            "OriginCustomHeaders": [
                                {
                                    "HeaderName": "FPJS_SECRET_NAME",
                                    "HeaderValue": {
                                        "Ref": "FingerprintIntegrationSettingsSecret"
                                    }
                                },
                                {
                                    "HeaderName": "FPJS_DEBUG",
                                    "HeaderValue": true
                                }
                            ],
                            "CustomOriginConfig": {
                                "HTTPPort": 80,
                                "HTTPSPort": 443,
                                "OriginKeepaliveTimeout": 5,
                                "OriginProtocolPolicy": "https-only",
                                "OriginReadTimeout": 30
                            }
                        }
                    ],
                    "PriceClass": "PriceClass_100"
                }
            }
        },
        "FpMgmtLambdaFunctionExecutionRole": {
            "Type": "AWS::IAM::Role",
            "DependsOn": [
                "MgmtSettingsSecret"
            ],
            "Metadata": {
                "SamResourceId": "FpMgmtLambdaFunctionExecutionRole"
            },
            "Properties": {
                "Description": "Management Lambda execution role",
                "RoleName": {
                    "Fn::Join": [
                        "-",
                        [
                            "fingerprint-pro-lambda-mgmt-role",
                            {
                                "Fn::Select": [
                                    4,
                                    {
                                        "Fn::Split": [
                                            "-",
                                            {
                                                "Fn::Select": [
                                                    2,
                                                    {
                                                        "Fn::Split": [
                                                            "/",
                                                            {
                                                                "Ref": "AWS::StackId"
                                                            }
                                                        ]
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    ]
                },
                "AssumeRolePolicyDocument": {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Effect": "Allow",
                            "Action": "sts:AssumeRole",
                            "Principal": {
                                "Service": [
                                    "lambda.amazonaws.com"
                                ]
                            }
                        }
                    ]
                },
                "Policies": [
                    {
                        "PolicyName": "LogsPolicy",
                        "PolicyDocument": {
                            "Version": "2012-10-17",
                            "Statement": [
                                {
                                    "Effect": "Allow",
                                    "Action": [
                                        "logs:CreateLogGroup",
                                        "logs:CreateLogStream",
                                        "logs:PutLogEvents"
                                    ],
                                    "Resource": "arn:aws:logs:*:*:*"
                                }
                            ]
                        }
                    },
                    {
                        "PolicyName": "AWSSecretAccess",
                        "PolicyDocument": {
                            "Version": "2012-10-17",
                            "Statement": [
                                {
                                    "Effect": "Allow",
                                    "Action": [
                                        "secretsmanager:GetSecretValue"
                                    ],
                                    "Resource": {
                                        "Fn::Sub": "$${MgmtSettingsSecret}"
                                    }
                                }
                            ]
                        }
                    },
                    {
                        "PolicyName": "S3LambdaDistributionAccess",
                        "PolicyDocument": {
                            "Version": "2012-10-17",
                            "Statement": [
                                {
                                    "Effect": "Allow",
                                    "Action": [
                                        "s3:GetObject",
                                        "s3:GetObjectVersion"
                                    ],
                                    "Resource": "arn:aws:s3:::fingerprint-pro-cloudfront-integration-lambda-function/releaseV2/lambda_latest.zip"
                                }
                            ]
                        }
                    },
                    {
                        "PolicyName": "FpLambdaUpdate",
                        "PolicyDocument": {
                            "Version": "2012-10-17",
                            "Statement": [
                                {
                                    "Effect": "Allow",
                                    "Action": [
                                        "lambda:ListVersionsByFunction",
                                        "lambda:GetFunction",
                                        "lambda:GetFunctionConfiguration",
                                        "lambda:EnableReplication",
                                        "lambda:UpdateFunctionCode",
                                        "lambda:PublishVersion"
                                    ],
                                    "Resource": [
                                        {
                                            "Fn::Join": [
                                                "",
                                                [
                                                    {
                                                        "Fn::Sub": "arn:aws:lambda:*:$${AWS::AccountId}:function:"
                                                    },
                                                    "fingerprint-pro-cloudfront-lambda-",
                                                    {
                                                        "Fn::Select": [
                                                            4,
                                                            {
                                                                "Fn::Split": [
                                                                    "-",
                                                                    {
                                                                        "Fn::Select": [
                                                                            2,
                                                                            {
                                                                                "Fn::Split": [
                                                                                    "/",
                                                                                    {
                                                                                        "Ref": "AWS::StackId"
                                                                                    }
                                                                                ]
                                                                            }
                                                                        ]
                                                                    }
                                                                ]
                                                            }
                                                        ]
                                                    },
                                                    ":*"
                                                ]
                                            ]
                                        },
                                        {
                                            "Fn::Join": [
                                                "",
                                                [
                                                    {
                                                        "Fn::Sub": "arn:aws:lambda:*:$${AWS::AccountId}:function:"
                                                    },
                                                    "fingerprint-pro-cloudfront-lambda-",
                                                    {
                                                        "Fn::Select": [
                                                            4,
                                                            {
                                                                "Fn::Split": [
                                                                    "-",
                                                                    {
                                                                        "Fn::Select": [
                                                                            2,
                                                                            {
                                                                                "Fn::Split": [
                                                                                    "/",
                                                                                    {
                                                                                        "Ref": "AWS::StackId"
                                                                                    }
                                                                                ]
                                                                            }
                                                                        ]
                                                                    }
                                                                ]
                                                            }
                                                        ]
                                                    }
                                                ]
                                            ]
                                        }
                                    ]
                                }
                            ]
                        }
                    },
                    {
                        "PolicyName": "CloudFrontUpdate",
                        "PolicyDocument": {
                            "Version": "2012-10-17",
                            "Statement": [
                                {
                                    "Effect": "Allow",
                                    "Action": [
                                        "cloudfront:GetDistribution",
                                        "cloudfront:UpdateDistribution",
                                        "cloudfront:GetDistributionConfig",
                                        "cloudfront:CreateInvalidation"
                                    ],
                                    "Resource": {
                                        "Fn::Join": [
                                            "",
                                            [
                                                {
                                                    "Fn::Sub": "arn:aws:cloudfront::$${AWS::AccountId}:distribution/"
                                                },
                                                {
                                                    "Fn::If": [
                                                        "CreateCloudFrontDistribution",
                                                        {
                                                            "Ref": "CloudFrontDistribution"
                                                        },
                                                        {
                                                            "Ref": "DistributionId"
                                                        }
                                                    ]
                                                }
                                            ]
                                        ]
                                    }
                                }
                            ]
                        }
                    }
                ],
                "ManagedPolicyArns": [
                    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
                ]
            }
        },
        "MgmtSettingsSecret": {
            "Type": "AWS::SecretsManager::Secret",
            "Properties": {
                "Name": {
                    "Fn::Join": [
                        "-",
                        [
                            "fingerprint-pro-mgmt-settings-secret",
                            {
                                "Fn::Select": [
                                    4,
                                    {
                                        "Fn::Split": [
                                            "-",
                                            {
                                                "Fn::Select": [
                                                    2,
                                                    {
                                                        "Fn::Split": [
                                                            "/",
                                                            {
                                                                "Ref": "AWS::StackId"
                                                            }
                                                        ]
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    ]
                },
                "GenerateSecretString": {
                    "IncludeSpace": false,
                    "ExcludePunctuation": true,
                    "PasswordLength": 30,
                    "GenerateStringKey": "token",
                    "SecretStringTemplate": {
                        "Fn::Sub": "{}"
                    }
                }
            }
        },
        "FingerprintProMgmtLambda": {
            "Type": "AWS::Serverless::Function",
            "DependsOn": [
                "FpMgmtLambdaFunctionExecutionRole",
                "MgmtSettingsSecret"
            ],
            "Properties": {
                "FunctionName": {
                    "Fn::Join": [
                        "-",
                        [
                            "fingerprint-pro-mgmt-lambda",
                            {
                                "Fn::Select": [
                                    4,
                                    {
                                        "Fn::Split": [
                                            "-",
                                            {
                                                "Fn::Select": [
                                                    2,
                                                    {
                                                        "Fn::Split": [
                                                            "/",
                                                            {
                                                                "Ref": "AWS::StackId"
                                                            }
                                                        ]
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    ]
                },
                "Handler": "fingerprintjs-pro-cloudfront-mgmt-lambda-function.handler",
                "Runtime": "nodejs20.x",
                "CodeUri": "s3://fingerprint-pro-cloudfront-integration-lambda-function/releaseV2/mgmt_lambda_latest.zip",
                "MemorySize": 128,
                "Timeout": 120,
                "Role": {
                    "Fn::GetAtt": [
                        "FpMgmtLambdaFunctionExecutionRole",
                        "Arn"
                    ]
                },
                "Environment": {
                    "Variables": {
                        "SettingsSecretName": {
                            "Ref": "MgmtSettingsSecret"
                        },
                        "LambdaFunctionName": {
                            "Ref": "FingerprintProCloudFrontLambda"
                        },
                        "LambdaFunctionArn": {
                            "Fn::GetAtt": [
                                "FingerprintProCloudFrontLambda",
                                "Arn"
                            ]
                        },
                        "CFDistributionId": {
                            "Fn::If": [
                                "CreateCloudFrontDistribution",
                                {
                                    "Ref": "CloudFrontDistribution"
                                },
                                {
                                    "Ref": "DistributionId"
                                }
                            ]
                        }
                    }
                }
            }
        },
        "MgmtFunctionURL": {
            "Type": "AWS::Lambda::Url",
            "DependsOn": [
                "FingerprintProMgmtLambda"
            ],
            "Properties": {
                "AuthType": "NONE",
                "TargetFunctionArn": {
                    "Fn::GetAtt": [
                        "FingerprintProMgmtLambda",
                        "Arn"
                    ]
                }
            }
        },
        "MgmtFunctionInvokePermission": {
            "Type": "AWS::Lambda::Permission",
            "DependsOn": [
                "FingerprintProMgmtLambda"
            ],
            "Properties": {
                "Action": "lambda:InvokeFunctionUrl",
                "FunctionName": {
                    "Ref": "FingerprintProMgmtLambda"
                },
                "FunctionUrlAuthType": "NONE",
                "Principal": "*"
            }
        }
    },
    "Outputs": {
        "LambdaFunctionName": {
            "Description": "Fingerprint Pro Lambda function name",
            "Value": {
                "Ref": "FingerprintProCloudFrontLambda"
            },
            "Export": {
                "Name": {
                    "Fn::Join": [
                        "-",
                        [
                            "fingerprint-pro-cloudfront-lambda",
                            {
                                "Fn::Select": [
                                    4,
                                    {
                                        "Fn::Split": [
                                            "-",
                                            {
                                                "Fn::Select": [
                                                    2,
                                                    {
                                                        "Fn::Split": [
                                                            "/",
                                                            {
                                                                "Ref": "AWS::StackId"
                                                            }
                                                        ]
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    ]
                }
            }
        },
        "LambdaFunctionVersion": {
            "Description": "Fingerprint Pro Lambda function version",
            "Value": {
                "Ref": "FingerprintProCloudFrontLambdaVersion"
            },
            "Export": {
                "Name": {
                    "Fn::Join": [
                        "-",
                        [
                            "fingerprint-pro-cloudfront-lambda-version",
                            {
                                "Fn::Select": [
                                    4,
                                    {
                                        "Fn::Split": [
                                            "-",
                                            {
                                                "Fn::Select": [
                                                    2,
                                                    {
                                                        "Fn::Split": [
                                                            "/",
                                                            {
                                                                "Ref": "AWS::StackId"
                                                            }
                                                        ]
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    ]
                }
            }
        },
        "CachePolicyName": {
            "Description": "Cache policy name",
            "Value": {
                "Ref": "FingerprintProCDNCachePolicy"
            },
            "Export": {
                "Name": {
                    "Fn::Join": [
                        "-",
                        [
                            "FingerprintProCDNCachePolicy",
                            {
                                "Fn::Select": [
                                    4,
                                    {
                                        "Fn::Split": [
                                            "-",
                                            {
                                                "Fn::Select": [
                                                    2,
                                                    {
                                                        "Fn::Split": [
                                                            "/",
                                                            {
                                                                "Ref": "AWS::StackId"
                                                            }
                                                        ]
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    ]
                }
            }
        },
        "CloudFrontDistributionId": {
            "Description": "CloudFront distribution Id used in the integration settings",
            "Value": {
                "Fn::If": [
                    "CreateCloudFrontDistribution",
                    {
                        "Ref": "CloudFrontDistribution"
                    },
                    {
                        "Ref": "DistributionId"
                    }
                ]
            },
            "Export": {
                "Name": {
                    "Fn::Join": [
                        "-",
                        [
                            "fingerprint-pro-cloudfront-distribution",
                            {
                                "Fn::Select": [
                                    4,
                                    {
                                        "Fn::Split": [
                                            "-",
                                            {
                                                "Fn::Select": [
                                                    2,
                                                    {
                                                        "Fn::Split": [
                                                            "/",
                                                            {
                                                                "Ref": "AWS::StackId"
                                                            }
                                                        ]
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    ]
                }
            }
        },
        "IsCloudFrontDistributionCreatedByDeployment": {
            "Description": "Indicate if the CloudFront distribution with attached Lambda function was created by deployment or not (depends on initial parameters)",
            "Value": {
                "Fn::If": [
                    "CreateCloudFrontDistribution",
                    "true",
                    "false"
                ]
            },
            "Export": {
                "Name": {
                    "Fn::Join": [
                        "-",
                        [
                            "is-cloudfront-distribution-created-by-deployment",
                            {
                                "Fn::Select": [
                                    4,
                                    {
                                        "Fn::Split": [
                                            "-",
                                            {
                                                "Fn::Select": [
                                                    2,
                                                    {
                                                        "Fn::Split": [
                                                            "/",
                                                            {
                                                                "Ref": "AWS::StackId"
                                                            }
                                                        ]
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    ]
                }
            }
        },
        "FingerprintProMgmtLambda": {
            "Description": "Fingerprint Pro Lambda function name",
            "Value": {
                "Ref": "FingerprintProMgmtLambda"
            },
            "Export": {
                "Name": {
                    "Fn::Join": [
                        "-",
                        [
                            "fingerprint-pro-mgmt-lambda",
                            {
                                "Fn::Select": [
                                    4,
                                    {
                                        "Fn::Split": [
                                            "-",
                                            {
                                                "Fn::Select": [
                                                    2,
                                                    {
                                                        "Fn::Split": [
                                                            "/",
                                                            {
                                                                "Ref": "AWS::StackId"
                                                            }
                                                        ]
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    ]
                }
            }
        },
        "MgmtLambdaFunctionUrl": {
            "Description": "Fingerprint Pro management Lambda function name",
            "Value": {
                "Fn::GetAtt": "MgmtFunctionURL.FunctionUrl"
            },
            "Export": {
                "Name": {
                    "Fn::Join": [
                        "-",
                        [
                            "fingerprint-pro-mgmt-lambda-url",
                            {
                                "Fn::Select": [
                                    4,
                                    {
                                        "Fn::Split": [
                                            "-",
                                            {
                                                "Fn::Select": [
                                                    2,
                                                    {
                                                        "Fn::Split": [
                                                            "/",
                                                            {
                                                                "Ref": "AWS::StackId"
                                                            }
                                                        ]
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    ]
                }
            }
        },
        "FingerprintIntegrationSettingsSecret": {
            "Description": "Fingerprint Pro CloudFront integration settings secret",
            "Value": {
                "Ref": "FingerprintIntegrationSettingsSecret"
            },
            "Export": {
                "Name": {
                    "Fn::Join": [
                        "-",
                        [
                            "fingerprint-pro-integration-settings-secret",
                            {
                                "Fn::Select": [
                                    4,
                                    {
                                        "Fn::Split": [
                                            "-",
                                            {
                                                "Fn::Select": [
                                                    2,
                                                    {
                                                        "Fn::Split": [
                                                            "/",
                                                            {
                                                                "Ref": "AWS::StackId"
                                                            }
                                                        ]
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    ]
                }
            }
        },
        "MgmtSettingsSecret": {
            "Description": "Fingerprint Pro Management Lambda settings secret",
            "Value": {
                "Ref": "MgmtSettingsSecret"
            },
            "Export": {
                "Name": {
                    "Fn::Join": [
                        "-",
                        [
                            "fingerprint-pro-mgmt-lambda-settings-secret",
                            {
                                "Fn::Select": [
                                    4,
                                    {
                                        "Fn::Split": [
                                            "-",
                                            {
                                                "Fn::Select": [
                                                    2,
                                                    {
                                                        "Fn::Split": [
                                                            "/",
                                                            {
                                                                "Ref": "AWS::StackId"
                                                            }
                                                        ]
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    ]
                }
            }
        }
    }
}
EOF

  capabilities = ["CAPABILITY_IAM", "CAPABILITY_AUTO_EXPAND", "CAPABILITY_NAMED_IAM"]
}

data "aws_cloudfront_distribution" "created_distribution" {
  id = aws_cloudformation_stack.fingerprint_cloudfront_v2_proxy_stack-via-terraform.outputs["CloudFrontDistributionId"]
}

# Add a CNAME recortd to point to the created CloudFront distribution, use your name server provider instead
resource "cloudflare_record" "cname_record" {
  zone_id = var.cloudflare_zone_id
  name    = var.subdomain_name
  value   = data.aws_cloudfront_distribution.created_distribution.domain_name
  type    = "CNAME"
  comment = "Fingerprint CloudFront v2 proxy integration via Terraform"
  ttl     = 3600
}
