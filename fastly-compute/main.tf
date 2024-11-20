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

locals {
  # Dynamically set API endpoint based on region:
  # empty -> api.fpjs.io
  # eu -> eu.api.fpjs.io
  # ap -> ap.api.fpjs.io
  api_hostname = var.region == "" ? "api.fpjs.io" : "${var.region}.api.fpjs.io"
}

# Create a Compute@Edge service
resource "fastly_service_compute" "fpjs_proxy" {
  name = var.service_name

  domain {
    name    = var.domain_name
    comment = "FPJS proxy domain"
  }

  backend {
    name              = local.api_hostname
    address           = local.api_hostname
    port              = 443
    use_ssl          = true
    ssl_cert_hostname = local.api_hostname
    ssl_sni_hostname  = local.api_hostname
    override_host     = local.api_hostname
  }

  backend {
    name              = "fpcdn.io"
    address           = "fpcdn.io"
    port              = 443
    use_ssl          = true
    ssl_cert_hostname = "fpcdn.io"
    ssl_sni_hostname  = "fpcdn.io"
    override_host     = "fpcdn.io"
  }

  package {
    filename         = "pkg/fingerprint-fastly-compute-proxy-integration.tar.gz"
    source_code_hash = filesha512("pkg/fingerprint-fastly-compute-proxy-integration.tar.gz")
  }

  force_destroy = true
}

# Create Config Store
resource "fastly_configstore" "fpjs_config" {
  name = "Fingerprint_Compute_Config_Store_${fastly_service_compute.fpjs_proxy.id}"
}

# Create Config Store Entries
resource "fastly_configstore_entries" "fpjs_config_entries" {
  store_id = fastly_configstore.fpjs_config.id
  entries = {
    "AGENT_SCRIPT_DOWNLOAD_PATH" = var.agent_script_download_path
    "GET_RESULT_PATH"            = var.get_result_path
  }
}

# Create Secret Store
resource "fastly_secretstore" "fpjs_secrets" {
  name = "Fingerprint_Compute_Secret_Store_${fastly_service_compute.fpjs_proxy.id}"
}

# Output the service ID and URL
output "service_id" {
  value = fastly_service_compute.fpjs_proxy.id
}

output "service_url" {
  value = "https://${var.domain_name}"
}

output "config_store_id" {
  value = fastly_configstore.fpjs_config.id
}

output "secret_store_id" {
  value = fastly_secretstore.fpjs_secrets.id
}

# Add this resource to handle the linking
resource "null_resource" "link_resources" {
  depends_on = [
    fastly_service_compute.fpjs_proxy,
    fastly_configstore.fpjs_config,
    fastly_secretstore.fpjs_secrets
  ]

  provisioner "local-exec" {
    command = <<EOT
      # Create new version
      FASTLY_API_TOKEN=${var.fastly_api_key} fastly service-version clone \
        --service-id=${fastly_service_compute.fpjs_proxy.id} \
        --version=active \
        --auto-yes
      
      # Add secret to secret store (using stdin to pass secret)
      echo "${var.proxy_secret}" | FASTLY_API_TOKEN=${var.fastly_api_key} fastly secret-store-entry create \
        --store-id=${fastly_secretstore.fpjs_secrets.id} \
        --name=PROXY_SECRET \
        --stdin
      
      # Create resource links
      FASTLY_API_TOKEN=${var.fastly_api_key} fastly resource-link create \
        --service-id=${fastly_service_compute.fpjs_proxy.id} \
        --resource-id=${fastly_configstore.fpjs_config.id} \
        --name="Fingerprint_Compute_Config_Store_${fastly_service_compute.fpjs_proxy.id}" \
        --version=latest \
        --auto-yes
      
      FASTLY_API_TOKEN=${var.fastly_api_key} fastly resource-link create \
        --service-id=${fastly_service_compute.fpjs_proxy.id} \
        --resource-id=${fastly_secretstore.fpjs_secrets.id} \
        --name="Fingerprint_Compute_Secret_Store_${fastly_service_compute.fpjs_proxy.id}" \
        --version=latest \
        --auto-yes
      
      # Activate the version
      FASTLY_API_TOKEN=${var.fastly_api_key} fastly service-version activate \
        --service-id=${fastly_service_compute.fpjs_proxy.id} \
        --version=latest \
        --auto-yes
    EOT
  }
}
 