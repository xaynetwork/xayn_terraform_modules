output "username" {
  description = "The name of the auto-generated Elasticsearch user"
  value       = aws_ssm_parameter.elasticsearch_username.value
  sensitive   = true
}

output "password_ssm_parameter_arn" {
  description = "ARN of the Elasticsearch password SSM parameter"
  value       = aws_ssm_parameter.elasticsearch_password.arn
}

output "url" {
  description = "URL of the Elasticsearch deployment"
  value       = aws_ssm_parameter.elasticsearch_url.value
  sensitive   = true
}

output "username_ssm_parameter_name" {
  description = "Name of the Elasticsearch username SSM parameter"
  value       = aws_ssm_parameter.elasticsearch_username.name
}

output "password_ssm_parameter_name" {
  description = "Name of the Elasticsearch password SSM parameter"
  value       = aws_ssm_parameter.elasticsearch_password.name
}

output "url_ssm_parameter_name" {
  description = "Name of the Elasticsearch URL SSM parameter"
  value       = aws_ssm_parameter.elasticsearch_url.name
}
