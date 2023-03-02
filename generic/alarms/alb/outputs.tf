output "arns" {
  description = "ARNs of the CloudWatch alarms."
  value = {
    services_http_5xx_error = try(module.services_http_5xx_error.cloudwatch_metric_alarm_arn, "")
    http_5xx_error          = try(module.http_5xx_error.cloudwatch_metric_alarm_arn, "")
    http_4xx_error          = try(module.http_4xx_error.cloudwatch_metric_alarm_arn, "")
  }
}
