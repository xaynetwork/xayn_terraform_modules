output "name" {
  description = "Name of the service"
  value       = module.service.name
}

output "log_group_name" {
  description = "Name of the users service log group"
  value       = module.service.log_group_name
}
