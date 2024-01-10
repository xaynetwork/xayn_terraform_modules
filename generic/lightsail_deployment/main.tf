resource "aws_lightsail_container_service_deployment_version" "this" {
  dynamic "container" {
    for_each = var.containers
    content {
      container_name = container.value.name
      image          = container.value.image
      command        = container.value.command
      environment    = container.value.envs
      ports          = container.value.port
    }
  }

  public_endpoint {
    container_name = var.public_container
    container_port = var.public_port

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
