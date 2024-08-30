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

# Create Cloudflare Worker
resource "cloudflare_workers_script" "worker" {
  account_id = var.account_id
  name       = var.worker_name
  content    = file("${path.module}/fingerprintjs-pro-cloudflare-worker.esm.js")
  module     = true 

  plain_text_binding {
    name = "AGENT_SCRIPT_DOWNLOAD_PATH"
    text = var.agent_script_download_path
  }

    plain_text_binding {
    name = "GET_RESULT_PATH"
    text = var.get_result_path
  }

    plain_text_binding {
    name = "PROXY_SECRET"
    text = var.proxy_secret
  }

    plain_text_binding {
    name = "WORKER_PATH"
    text = var.worker_path_env
  }
}

resource "cloudflare_workers_domain" "example" {
  account_id = var.account_id
  hostname   = var.subdomain
  service    = var.worker_name
  zone_id    = var.zone_id
}