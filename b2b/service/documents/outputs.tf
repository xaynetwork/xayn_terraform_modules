output "alarm_arns" {
  description = "ARNs of the CloudWatch alarms."
  value       = module.alarms.arns
}

output "execution_role_arn" {
  description = "The role ARN of the task role that is used for outgoing requests like towards tika or sagemaker"
  value       = aws_iam_role.task_role[0].arn
}
