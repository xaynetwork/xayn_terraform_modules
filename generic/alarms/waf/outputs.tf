output "arns" {
  description = "ARNs of the CloudWatch alarms."
  value = {
    all_requests_blocked = try(module.all_requests_blocked.cloudwatch_metric_alarm_arn, "")
    ip_rate_limit        = try(module.ip_rate_limit.cloudwatch_metric_alarm_arn, "")
  }
}
