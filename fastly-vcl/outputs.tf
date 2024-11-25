output "service_id" {
  value = fastly_service_vcl.fpjs_proxy.id
}

output "service_url" {
  value = "https://${var.domain_name}"
} 