module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "2.0"

  zones = {
    (var.hosted_zone_name) = {
      comment = "Zone hosted in ${var.hosted_zone_name}"
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

  zone_name = keys(module.zones.route53_zone_zone_id)[0]

  records = var.records

  depends_on = [module.zones]
}
