output "name" {
  description = "ARN of the ECS task"
  value       = aws_ecs_task_definition.this.arn
}

output "log_group_name" {
  description = "Name of the ECS task log group"
  value       = local.log_group_name
}
