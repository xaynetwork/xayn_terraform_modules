output "name" {
  description = "Name of the task execution role"
  value       = aws_iam_role.ecs_task_execution_role.name
}

output "arn" {
  description = "ARN of the task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}
