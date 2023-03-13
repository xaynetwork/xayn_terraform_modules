output "arns" {
  description = "ARN of the CloudWatch alarm."
  value       = try(aws_cloudwatch_composite_alarm.this.arn, "")
}
