output "api_gateway_url" {
  description = "API Gateway URL"
  value       = aws_api_gateway_stage.tenant.invoke_url
}

output "alarm_ids" {
  description = "IDs of the CloudWatch alarms."
  value       = module.alarms.ids
}
