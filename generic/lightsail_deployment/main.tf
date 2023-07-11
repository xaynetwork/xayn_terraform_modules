resource "aws_lightsail_container_service_deployment_version" "this" {
  count = var.private_registry_access && var.ecr_role != null ? 1 : var.private_registry_access ? 0 : 1
  container {
    container_name = var.service_name
    image          = var.container_image

    command = var.container_command

    environment = var.environmental_variables

    ports = var.ports
  }

  public_endpoint {
    container_name = var.service_name
    container_port = keys(var.ports)[0]

    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout_seconds     = 2
      interval_seconds    = 5
      path                = var.health_check_path
      success_codes       = var.health_success_codes
    }
  }

  service_name = var.service_name
}
