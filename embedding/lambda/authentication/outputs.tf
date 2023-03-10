output "invoke_authentication_arn" {
  description = "ARN to be used for invoking the `authentication` lambda"
  value       = module.function.invoke_arn
}

output "authentication_arn" {
  description = "ARN of the the `authentication` lambda"
  value       = module.function.arn
}

output "api_key_id" {
  description = "ID of the API key"
  value       = aws_api_gateway_api_key.tenant.id
}
