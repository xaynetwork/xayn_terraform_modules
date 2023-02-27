output "ids" {
  description = "IDs of the CloudWatch alarms."
  value = {
    http_5xx_error      = try(module.http_5xx_error.cloudwatch_metric_alarm_id, "")
    integration_latency = try(module.integration_latency.cloudwatch_metric_alarm_id, "")
    latency             = try(module.latency.cloudwatch_metric_alarm_id, "")
  }
}
