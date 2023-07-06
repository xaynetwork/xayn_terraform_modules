output "invoke_authentication_arn" {
  description = "ARN to be used for invoking the `authentication` lambda"
  value       = module.authentication_function.lambda_function_invoke_arn
}

output "authentication_arn" {
  description = "ARN of the the `authentication` lambda"
  value       = module.authentication_function.lambda_function_arn
}

output "provisioning_arn" {
  description = "ARN of the the `provisioning` lambda"
  value       = module.provisioning_function.lambda_function_arn
}

output "provisioning_role_arn" {
  description = "ARN of the role of the `provisioning` lambda"
  value       = module.provisioning_function.lambda_role_arn
}
