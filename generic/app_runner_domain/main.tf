data "aws_route53_zone" "this" {
  name = var.domain_name
}

resource "aws_route53_record" "validation_records_linglinger_1" {
  name    = tolist(var.custom_domain_association_certificate_validation_records)[0].name
  type    = tolist(var.custom_domain_association_certificate_validation_records)[0].type
  records = [tolist(var.custom_domain_association_certificate_validation_records)[0].value]
  ttl     = 300
  zone_id = data.aws_route53_zone.this.id
}

resource "aws_route53_record" "validation_records_linglinger_2" {
  name    = tolist(var.custom_domain_association_certificate_validation_records)[1].name
  type    = tolist(var.custom_domain_association_certificate_validation_records)[1].type
  records = [tolist(var.custom_domain_association_certificate_validation_records)[1].value]
  ttl     = 300
  zone_id = data.aws_route53_zone.this.id
}

resource "aws_route53_record" "validation_records_linglinger_3" {
  name    = tolist(var.custom_domain_association_certificate_validation_records)[2].name
  type    = tolist(var.custom_domain_association_certificate_validation_records)[2].type
  records = [tolist(var.custom_domain_association_certificate_validation_records)[2].value]
  ttl     = 300
  zone_id = data.aws_route53_zone.this.id
}

resource "aws_route53_record" "custom_domain" {
  name    = var.subdomain_name
  type    = "CNAME"
  records = [var.service_url]
  ttl     = 300
  zone_id = data.aws_route53_zone.this.id
}
