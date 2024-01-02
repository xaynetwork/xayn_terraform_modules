output "service_public_url" {
  description = "The url to access the service"
  value       = aws_lightsail_container_service.this.url
}

output "service_private_domain" {
  description = "The private domain name of the container service"
  value       = aws_lightsail_container_service.this.private_domain_name
}
