terraform {
  required_providers {
    fastly = {
      source  = "fastly/fastly"
      version = "~> 5.15.0"
    }
  }
}

provider "fastly" {
  api_key = var.fastly_api_key
}