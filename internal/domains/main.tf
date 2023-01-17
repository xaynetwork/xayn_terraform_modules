module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "2.0"

  zones = {
    var.hosted_zone_name = {
      comment = "Zone hosted in ${var.hosted_zone_name} "
    }
  }

  tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
    }
  )
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "2.0"

  zone_name = module.zones.route53_zone_zone_id

  dynamic "records" {
    for_each = var.records
    content {
      record_name    = records.value.record_name
      record_type    = records.value.record_type
      record_ttl     = records.value.record_ttl
      record_records = records.value.record_records
    }
  }

  depends_on = [module.zones]
}
