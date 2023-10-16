locals {
  user_script = file("user_data.sh")
}

resource "aws_lightsail_instance" "this" {
  name              = var.service_name
  availability_zone = var.zone
  blueprint_id      = var.blueprint_id
  bundle_id         = var.bundle_id
  user_data         = var.user_data == null ? local.user_script : var.user_data
}

# Domain settings
data "aws_route53_zone" "this" {
  name = var.domain_name
}

resource "aws_route53_record" "custom_domain" {
  name    = var.subdomain_name
  type    = "A"
  records = [aws_lightsail_instance.this.public_ip_address]
  ttl     = 300
  zone_id = data.aws_route53_zone.this.id
}
