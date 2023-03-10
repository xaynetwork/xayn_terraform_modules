output "arn" {
  description = "ARN of the lambda role"
  value       = aws_iam_role.lambda.arn
}

output "name" {
  description = "Name of the lambda role"
  value       = aws_iam_role.lambda.name
}
