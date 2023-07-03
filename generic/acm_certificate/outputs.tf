output "certificate_validation_arn" {
  description = "Certificate Validation ARN"
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "domain_name" {
  description = "The name of the domain for which the certificate was created"
  value       = var.domain_name
}
