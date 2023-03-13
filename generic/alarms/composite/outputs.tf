output "arn" {
  description = "ARN of the CloudWatch alarm."
  value       = try(aws_cloudwatch_composite_alarm.this[0].arn, "")
}
