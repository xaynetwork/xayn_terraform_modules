output "endpoint_url" {
  description = "The URL of the endpoint."
  value       = local.endpoint_url
}

output "endpoint_url_ssm_name" {
  description = "Name of the endpoint URL SSM parameter"
  value       = module.endpoint_url.ssm_parameter_name
}

output "endpoint_name" {
  description = "Name of the endpoint."
  value       = try(aws_sagemaker_endpoint.this[0].name, null)
}
