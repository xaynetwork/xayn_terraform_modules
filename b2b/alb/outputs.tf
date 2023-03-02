output "load_balancer_dns" {
  description = "DNS name for the ALB endpoint"
  value       = aws_lb.this.dns_name
}

output "listener_arn" {
  description = "ARN of the ALB listener"
  value       = aws_lb_listener.listener.arn
}

output "id" {
  description = "ID of the ALB"
  value       = aws_lb.this.id
}

output "listener_port" {
  description = "Port of the ALB listener"
  value       = var.listener_port
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = module.security_group.security_group_id
}

output "alarm_arns" {
  description = "ARNs of the CloudWatch alarms."
  value       = module.alarms.arns
}
