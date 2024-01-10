output "postgres_url" {
  description = "DB URL"
  value       = aws_ssm_parameter.postgres_url.value
  sensitive   = true
}

output "postgres_cluster_arn" {
  description = "ARN of the postgres cluster"
  value       = aws_rds_cluster.this.arn
}

output "postgres_username" {
  description = "Aurora username"
  value       = aws_ssm_parameter.postgres_username.value
  sensitive   = true
}

output "postgres_username_ssm_parameter_arn" {
  description = "ARN of the aurora username SSM parameter"
  value       = aws_ssm_parameter.postgres_username.arn
}

output "postgres_password_ssm_parameter_arn" {
  description = "ARN of the aurora password SSM parameter"
  value       = aws_ssm_parameter.postgres_password.arn
}

output "postgres_url_ssm_parameter_arn" {
  description = "ARN of the aurora URL SSM parameter"
  value       = aws_ssm_parameter.postgres_url.arn
}


output "postgres_username_ssm_parameter_name" {
  description = "Name of the aurora username SSM parameter"
  value       = aws_ssm_parameter.postgres_username.name
}

output "postgres_password_ssm_parameter_name" {
  description = "Name of the aurora password SSM parameter"
  value       = aws_ssm_parameter.postgres_password.name
}

output "postgres_url_ssm_parameter_name" {
  description = "Name of the aurora URL SSM parameter"
  value       = aws_ssm_parameter.postgres_url.name
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = module.security_group.security_group_id
}

output "alarm_arns" {
  description = "ARNs of the CloudWatch alarms."
  value       = module.alarms.arns
}
