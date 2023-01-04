output "id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}
