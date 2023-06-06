data "aws_route53_zone" "this" {
  name = var.domain_name
}

resource "aws_route53_record" "validation_records_linglinger" {
  count   = length(var.certificate_validation_records)
  name    = var.certificate_validation_records[count.index].name
  type    = var.certificate_validation_records[count.index].type
  records = [var.certificate_validation_records[count.index].value]
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
