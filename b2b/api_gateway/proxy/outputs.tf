output "api_gateway_url" {
  description = "API Gateway URL"
  value       = aws_api_gateway_stage.tenant.invoke_url
}

output "api_gateway_name" {
  description = "Name of the API Gateway"
  value       = local.api_name
}
