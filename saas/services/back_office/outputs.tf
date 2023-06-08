output "alarm_arns" {
  description = "ARNs of the CloudWatch alarms."
  value       = try(module.alarms[0].arns, null)
}
