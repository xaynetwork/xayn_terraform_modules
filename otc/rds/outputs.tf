output "db_private_ip" {
  value = opentelekomcloud_rds_instance_v3.instance.private_ips
}

output "db_data" {
  value     = opentelekomcloud_rds_instance_v3.instance.db
  sensitive = true
}
