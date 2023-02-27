output "ids" {
  description = "IDs of the CloudWatch alarms."
  value = {
    http_5xx_error      = try(module.http_5xx_error.id, "")
    integration_latency = try(module.integration_latency.id, "")
    latency             = try(module.latency.id, "")
  }
}
