output "endpoint_url" {
  description = "The URL of the endpoint."
  value       = local.endpoint_url
}

output "endpoint_url_ssn_name" {
  description = "Name of the endpoint URL SSM parameter"
  value       = module.endpoint_url.ssm_parameter_name
}
