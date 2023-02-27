output "ids" {
  description = "IDs of the CloudWatch alarms."
  value = {
    cpu_usage = try(module.cpu_usage.cloudwatch_metric_alarm_id, "")
    log_error = try(module.log_error.cloudwatch_metric_alarm_id, "")
  }
}
