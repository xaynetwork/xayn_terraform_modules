output "kms_arn" {
  description = "ARN of the KMS"
  value       = aws_kms_key.this.arn
}

output "kms_alias_arn" {
  description = "Alias ARN of the KMS"
  value       = aws_kms_alias.this.arn
}
