output "ids" {
  description = "IDs of the CloudWatch alarms."
  value = {
    all_requests         = try(module.all_requests.cloudwatch_metric_alarm_id, "")
    all_blocked_requests = try(module.all_blocked_requests.cloudwatch_metric_alarm_id, "")
    ip_rate_limit        = try(module.ip_rate_limit.cloudwatch_metric_alarm_id, "")
  }
}
