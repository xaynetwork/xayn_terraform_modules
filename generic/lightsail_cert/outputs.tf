output "lightsail_cert_name" {
  value = aws_lightsail_certificate.this.name
}

output "lightsail_cert_subdomain" {
  value = var.subdomain_name
}

output "lightsail_cert_domain" {
  value = var.subdomain_name
}
