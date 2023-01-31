output "policy_arn" {
  description = "ARN of the policy"
  value       = aws_iam_policy.this.arn
}
