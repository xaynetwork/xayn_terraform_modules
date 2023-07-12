output "service" {
  description = "Back office service."
  value       = module.service
}

output "alarm_arns" {
  description = "ARNs of the CloudWatch alarms."
  value       = try(module.alarms[0].arns, null)
}
