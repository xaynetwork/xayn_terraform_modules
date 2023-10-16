output "public_ip_address" {
  value = aws_lightsail_instance.this.public_ip_address
}

output "user_name" {
  description = "Connect with ssh://username@public_ip after downloading the lightsail key from the console"
  value       = aws_lightsail_instance.this.username
}

output "domain_name" {
  value = var.subdomain_name
}

