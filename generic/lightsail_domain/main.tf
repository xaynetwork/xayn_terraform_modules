data "aws_route53_zone" "this" {
  name = var.domain_name
}

locals {
  url_no_protocol = replace(var.service_url, "https://", "")
}

resource "aws_route53_record" "validation_records_linglinger" {
  count   = length(var.certificate_validation_records)
  name    = var.certificate_validation_records[count.index].name
  type    = "CNAME"
  records = [var.certificate_validation_records[count.index].value]
  ttl     = 300
  zone_id = data.aws_route53_zone.this.id
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

resource "aws_lightsail_certificate" "test" {
  name                      = "test"
  domain_name               = "testdomain.com"
  subject_alternative_names = ["www.testdomain.com"]
}
