output "arns" {
  description = "ARNs of the CloudWatch alarms."
  value = {
    http_5xx_error    = try(module.http_5xx_error.cloudwatch_metric_alarm_arn, "")
    latency           = try(module.latency.cloudwatch_metric_alarm_arn, "")
    latency_by_method = try(module.latency_by_method.cloudwatch_metric_alarm_arn, "")
    error_rate        = try(module.error_rate.cloudwatch_metric_alarm_arn, "")
  }
}
