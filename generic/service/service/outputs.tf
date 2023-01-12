output "name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "log_group_name" {
  description = "Name of the ECS service log group"
  value       = local.log_group_name
}
