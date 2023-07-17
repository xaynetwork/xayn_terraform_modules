output "endpoint_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this endpoint."
  value       = aws_sagemaker_endpoint.this.arn
}

output "endpoint_name" {
  description = "The name of the endpoint."
  value       = aws_sagemaker_endpoint.this.name
}

output "endpoint" {
  value = aws_sagemaker_endpoint.this
}

output "endpoint_config" {
  value = aws_sagemaker_endpoint_configuration.this
}
