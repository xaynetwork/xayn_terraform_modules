# Domain settings
data "aws_route53_zone" "this" {
  count = var.domain_name != "" ? 1 : 0
  name  = var.domain_name
}

locals {
  url_no_protocol       = replace(replace(aws_lightsail_container_service.this.url, "https://", ""), "//$/", "")
  custom_domain_zone_id = var.domain_name != "" ? data.aws_route53_zone.this[0].id : ""
}

resource "aws_route53_record" "custom_domain" {
  count   = var.domain_name != "" ? 1 : 0
  name    = var.subdomain_name
  type    = "CNAME"
  records = [local.url_no_protocol]
  ttl     = 300
  zone_id = local.custom_domain_zone_id
}

resource "aws_route53_record" "www_custom_domain" {
  count   = var.domain_name != "" ? 1 : 0
  name    = "www.${var.subdomain_name}"
  type    = "CNAME"
  records = [local.url_no_protocol]
  ttl     = 300
  zone_id = local.custom_domain_zone_id
}

resource "aws_lightsail_container_service" "this" {
  name        = var.service_name
  power       = var.power
  scale       = var.node_number
  is_disabled = false

  private_registry_access {
    ecr_image_puller_role {
      is_active = var.private_registry_access
    }
  }

  dynamic "public_domain_names" {
    for_each = var.domain_name != "" ? [1] : []
    content {
      certificate {
        certificate_name = var.certificate_name
        domain_names = [
          var.subdomain_name,
          "www.${var.subdomain_name}"
        ]
      }
    }
  }
}

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

  depends_on = [aws_lightsail_container_service.this]
}
