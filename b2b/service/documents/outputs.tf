output "alarm_arns" {
  description = "ARNs of the CloudWatch alarms."
  value       = module.alarms.arns
}

output "execution_role_arn" {
  description = "ARN of the role of the `provisioning` lambda"
  value       = module.task_role.arn
}
