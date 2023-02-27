output "alarm_ids" {
  description = "IDs of the CloudWatch alarms."
  value       = module.alarms.ids
}
