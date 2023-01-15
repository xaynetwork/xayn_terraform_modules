output "arn" {
  description = "The ARN of the API Gateway Web ACL"
  value       = aws_wafv2_web_acl.api_gateway.arn
}
