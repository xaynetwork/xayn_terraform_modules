output "ids" {
  description = "IDs of the CloudWatch alarms."
  value = {
    cpu_usage = try(module.cpu_usage.id, "")
    log_error = try(module.log_error.id, "")
  }
}
