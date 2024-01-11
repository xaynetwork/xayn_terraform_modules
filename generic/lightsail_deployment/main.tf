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
      healthy_threshold   = var.health_check.healthy_threshold
      unhealthy_threshold = var.health_check.unhealthy_threshold
      timeout_seconds     = var.health_check.timeout_sec
      interval_seconds    = var.health_check.interval_sec
      path                = var.health_check.check_path
      success_codes       = var.health_check.success_codes
    }
  }

  service_name = var.service_name
}
