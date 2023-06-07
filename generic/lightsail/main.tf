resource "aws_lightsail_container_service" "this" {
  name        = var.service_name
  power       = var.power
  scale       = var.node_number
  is_disabled = false

  private_registry_access {
    ecr_image_puller_role {
      is_active = true
    }
  }

  public_domain_names {
    certificate {
      certificate_name = aws_lightsail_certificate.this.name
      domain_names = var.custom_domain
    }
  }
}

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
  repository = var.repository_name
  policy     = data.aws_iam_policy_document.this.json
}

resource "aws_lightsail_container_service_deployment_version" "example" {
  container {
    container_name = var.service_name
    image          = var.container_image

    command = []

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
      path                = "/"
      success_codes       = "200-499"
    }
  }

  service_name = aws_lightsail_container_service.this.name
}


resource "aws_lightsail_certificate" "this" {
  name                      = "${var.service_name}-certificate"
  domain_name               = var.custom_domain
  subject_alternative_names = ["www.${var.custom_domain}"]
}
