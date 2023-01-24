output "hosted_zone_id" {
  value = module.zones.output.route53_zone_zone_id
}

output "name_servers" {
  value = module.zones.output.route53_zone_name_servers
}
