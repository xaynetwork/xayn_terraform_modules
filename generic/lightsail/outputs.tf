output "lightsail_private_registry" {
  value = aws_lightsail_container_service.this.private_registry_access
}
