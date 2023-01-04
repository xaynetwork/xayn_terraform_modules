output "postgres_username" {
  description = "Postgres username"
  value       = aws_ssm_parameter.postgres_username.value
  sensitive   = true
}

output "postgres_password_ssm_parameter_arn" {
  description = "ARN of the postgres password SSM parameter"
  value       = aws_ssm_parameter.postgres_password.arn
}

output "postgres_url" {
  description = "Postgres URL"
  value       = aws_ssm_parameter.postgres_url.value
  sensitive   = true
}

output "postgres_username_ssm_parameter_name" {
  description = "Name of the postgres username SSM parameter"
  value       = aws_ssm_parameter.postgres_username.name
}

output "postgres_password_ssm_parameter_name" {
  description = "Name of the postgres password SSM parameter"
  value       = aws_ssm_parameter.postgres_password.name
}

output "postgres_url_ssm_parameter_name" {
  description = "Name of the postgres URL SSM parameter"
  value       = aws_ssm_parameter.postgres_url.name
}
