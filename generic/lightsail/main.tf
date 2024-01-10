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
