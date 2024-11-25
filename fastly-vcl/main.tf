resource "fastly_service_vcl" "fpjs_proxy" {
  name = "fingerprint-pro-fastly-vcl-proxy-integration"
  
  domain {
    name    = var.domain_name
    comment = "FPJS proxy domain"
  }

  backend {
    name              = "fpjs_origin"
    address           = var.origin_address
    port              = 443
    use_ssl          = true
    ssl_cert_hostname = var.origin_address
    ssl_sni_hostname  = var.origin_address
  }

  dictionary {
    name = "fingerprint_config"
  }

  vcl {
    name    = "fingerprint_proxy_integration"
    content = file("${path.module}/pkg/fingerprint-pro-fastly-vcl-integration.vcl")
    main    = true
  }

  force_destroy = true
}

resource "fastly_service_dictionary_items" "config_items" {
  service_id    = fastly_service_vcl.fpjs_proxy.id
  dictionary_id = one(fastly_service_vcl.fpjs_proxy.dictionary).dictionary_id

  items = {
    PROXY_SECRET               = var.proxy_secret
    INTEGRATION_PATH          = var.integration_path
    AGENT_SCRIPT_DOWNLOAD_PATH = var.agent_script_download_path
    GET_RESULT_PATH           = var.get_result_path
  }
} 