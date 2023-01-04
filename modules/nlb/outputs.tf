output "arn" {
  value       = aws_lb.this.arn
  description = "ARN of the network load balancer"
}

output "dns_name" {
  value       = aws_lb.this.dns_name
  description = "DNS name of the network load balancer"
}
