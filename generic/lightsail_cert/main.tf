data "aws_route53_zone" "this" {
  name = var.domain_name
}

resource "aws_route53_record" "validation_records_linglinger" {
  count   = length(aws_lightsail_certificate.this.domain_validation_options)
  name    = aws_lightsail_certificate.this.domain_validation_options[count.index].resource_record_name
  type    = aws_lightsail_certificate.this.domain_validation_options[count.index].resource_record_type
  records = [aws_lightsail_certificate.this.domain_validation_options[count.index].resource_record_value]
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
