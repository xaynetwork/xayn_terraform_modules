output "lightsail_service_name" {
  description = "Role created for lightsail use"
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
