output "lightsail_cert" {
  value = aws_lightsail_certificate.test.domain_validation_options
}
