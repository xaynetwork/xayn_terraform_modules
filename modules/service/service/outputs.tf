output "name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.this.name
}
