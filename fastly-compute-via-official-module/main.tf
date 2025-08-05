terraform {
  required_version = ">=1.5"
}

module "fingerprint_fastly_compute_integration" {
  source                     = "fingerprintjs/compute-fingerprint-proxy-integration/fastly"
  version = "1.0.0-rc.2"
  fastly_api_token           = var.fastly_api_token
  integration_domain         = var.integration_domain
  service_id                 = var.service_id
  agent_script_download_path = var.agent_script_download_path
  get_result_path            = var.get_result_path
  manage_fastly_config_store_entries = true
}