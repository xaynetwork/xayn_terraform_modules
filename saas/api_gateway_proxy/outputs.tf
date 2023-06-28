output "api_gateway_url" {
  description = "API Gateway URL"
  value       = aws_api_gateway_stage.api.invoke_url
}

output "alarm_arns" {
  description = "ARNs of the CloudWatch alarms."
  value       = module.alarms.arns
}

output "rest_api_id" {
  description = "The rest api id."
  value       = aws_api_gateway_stage.api.rest_api_id
}

output "rest_api_stage_name" {
  description = "The name of the rest api stage"
  value       = aws_api_gateway_stage.api.stage_name
}

output "rest_api_arn" {
  description = "The ARN of the rest api stage"
  value       = aws_api_gateway_stage.api.arn
}
