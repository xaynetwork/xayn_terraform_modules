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
