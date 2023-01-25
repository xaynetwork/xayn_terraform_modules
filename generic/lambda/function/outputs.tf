output "invoke_arn" {
  description = "ARN to be used for invoking the lambda"
  value       = aws_lambda_function.this.invoke_arn
}

output "arn" {
  description = "ARN of the lambda"
  value       = aws_lambda_function.this.arn
}
