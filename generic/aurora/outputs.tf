output "postgres_url" {
  description = "DB URL"
  value       = aws_ssm_parameter.postgres_url.value
  sensitive   = true
}

output "postgres_cluster_arn" {
  description = "ARN of the postgres cluster"
  value       = module.aurora_postgresql_v2.cluster_arn
}

output "postgres_username" {
  description = "Postgres username"
  value       = aws_ssm_parameter.postgres_username.value
  sensitive   = true
}

output "postgres_username_ssm_parameter_name" {
  description = "Name of the postgres username SSM parameter"
  value       = aws_ssm_parameter.postgres_username.name
}

output "postgres_url_ssm_parameter_name" {
  description = "Name of the postgres URL SSM parameter"
  value       = aws_ssm_parameter.postgres_url.name
}

output "postgres_password_ssm_parameter_arn" {
  description = "ARN of the postgres password SSM parameter"
  value       = aws_ssm_parameter.postgres_password.arn
}

output "postgres_password_ssm_parameter_name" {
  description = "Name of the postgres password SSM parameter"
  value       = aws_ssm_parameter.postgres_password.name
}

output "database_name" {
  description = "Name of the postgres database"
  value       = var.database_name
}

output "alarm_arns" {
  description = "ARNs of the CloudWatch alarms."
  value       = module.alarms.arns
}
