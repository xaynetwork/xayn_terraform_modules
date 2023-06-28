output "invoke_authentication_arn" {
  description = "ARN to be used for invoking the `authentication` lambda"
  value       = module.authentication_function.invoke_arn
}

output "authentication_arn" {
  description = "ARN of the the `authentication` lambda"
  value       = module.authentication_function.arn
}

output "invoke_provisioning_arn" {
  description = "ARN to be used for invoking the `authentication` lambda"
  value       = module.provisioning_function.invoke_arn
}

output "provisioning_arn" {
  description = "ARN of the the `provisioning` lambda"
  value       = module.provisioning_function.arn
}

output "provisioning_role_arn" {
  description = "ARN of the role of the `provisioning` lambda"
  value       = module.role_prov.arn
}
