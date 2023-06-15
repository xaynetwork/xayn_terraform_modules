# ECR Settings
data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_lightsail_container_service.this.private_registry_access[0].ecr_image_puller_role[0].principal_arn]
    }

    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
  }
}

resource "aws_ecr_repository_policy" "this" {
  count      = var.private_registry_access ? 1 : 0
  repository = var.repository_name
  policy     = data.aws_iam_policy_document.this.json
}

# Lightsail Configuration
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

  public_domain_names {
    certificate {
      certificate_name = var.certificate_name
      domain_names = [
        var.subdomain_name,
        "www.${var.subdomain_name}"
      ]
    }
  }
}

resource "aws_lightsail_container_service_deployment_version" "this" {
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

  service_name = aws_lightsail_container_service.this.name
}

# Domain settings
data "aws_route53_zone" "this" {
  name = var.domain_name
}

locals {
  url_no_protocol = replace(replace(aws_lightsail_container_service.this.url, "https://", ""), "//$/", "")
}

resource "aws_route53_record" "custom_domain" {
  name    = var.subdomain_name
  type    = "CNAME"
  records = [local.url_no_protocol]
  ttl     = 300
  zone_id = data.aws_route53_zone.this.id
}

resource "aws_route53_record" "www_custom_domain" {
  name    = "www.${var.subdomain_name}"
  type    = "CNAME"
  records = [local.url_no_protocol]
  ttl     = 300
  zone_id = data.aws_route53_zone.this.id
}
