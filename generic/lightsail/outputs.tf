output "lightsail_service_name" {
  description = "Service name for the containers"
  value       = var.service_name
}

output "lightsail_role" {
  description = "Role created for lightsail use"
  value       = aws_lightsail_container_service.this.private_registry_access[0].ecr_image_puller_role[0].principal_arn
}

output "private_registry_access" {
  description = "Describes a request to configure an Amazon Lightsail container service to access private container image repositories"
  value       = var.private_registry_access
}

output "service_public_url" {
  description = "The url to access the service"
  value       = aws_lightsail_container_service.this.url
}

output "service_private_domain" {
  description = "The private domain name of the container service"
  value       = aws_lightsail_container_service.this.private_domain_name
}
