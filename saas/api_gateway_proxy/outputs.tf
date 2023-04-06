output "api_gateway_url" {
  description = "API Gateway URL"
  value       = aws_api_gateway_stage.api.invoke_url
}

output "alarm_arns" {
  description = "ARNs of the CloudWatch alarms."
  value       = module.alarms.arns
}
