data "aws_route53_zone" "this" {
  name = var.domain_name
}

resource "aws_route53_record" "validation_records_linglinger" {
  for_each = aws_lightsail_certificate.this.domain_validation_options

  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 300
  zone_id = data.aws_route53_zone.this.id
  depends_on = [
    aws_lightsail_certificate.this
  ]
}

resource "aws_lightsail_certificate" "this" {
  name                      = var.subdomain_name
  domain_name               = var.subdomain_name
  subject_alternative_names = ["www.${var.subdomain_name}"]
}
