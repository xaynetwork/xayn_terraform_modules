output "hosted_zone_id" {
  description = "Zone ID of the hosted domain"
  value = module.zones.output.route53_zone_zone_id
}

output "name_servers" {
  description = "Name servers of the hosted domain"
  value = module.zones.output.route53_zone_name_servers
}
