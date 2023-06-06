output "postgres_url" {
  description = "DB URL"
  value       = aws_ssm_parameter.postgres_url.value
  sensitive   = true
}

output "postgres_username" {
  description = "Aurora username"
  value       = aws_ssm_parameter.postgres_username.value
  sensitive   = true
}

output "postgres_username_ssm_parameter_name" {
  description = "Name of the aurora username SSM parameter"
  value       = aws_ssm_parameter.postgres_username.name
}

output "postgres_url_ssm_parameter_name" {
  description = "Name of the aurora URL SSM parameter"
  value       = aws_ssm_parameter.postgres_url.name
}

output "alarm_arns" {
  description = "ARNs of the CloudWatch alarms."
  value       = module.alarms.arns
}
