output "invoke_authentication_arn" {
  description = "ARN to be used for invoking the `authentication` lambda"
  value       = module.authentication_function.invoke_arn
}

output "authentication_arn" {
  description = "ARN of the the `authentication` lambda"
  value       = module.authentication_function.arn
}