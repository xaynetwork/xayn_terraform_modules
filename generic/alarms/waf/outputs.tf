output "arns" {
  description = "ARNs of the CloudWatch alarms."
  value = {
    all_requests         = try(module.all_requests.cloudwatch_metric_alarm_arn, "")
    all_blocked_requests = try(module.all_blocked_requests.cloudwatch_metric_alarm_arn, "")
    ip_rate_limit        = try(module.ip_rate_limit.cloudwatch_metric_alarm_arn, "")
  }
}
