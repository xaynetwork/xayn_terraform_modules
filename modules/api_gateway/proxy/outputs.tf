output "api_gateway_url" {
  value       = aws_api_gateway_stage.tenant.invoke_url
  description = "API Gateway URL"
}
