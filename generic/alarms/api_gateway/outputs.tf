output "arns" {
  description = "ARNs of the CloudWatch alarms."
  value = {
    http_5xx_error      = try(module.http_5xx_error.cloudwatch_metric_alarm_arn, "")
    integration_latency = try(module.integration_latency.cloudwatch_metric_alarm_arn, "")
    latency             = try(module.latency.cloudwatch_metric_alarm_arn, "")
  }
}
