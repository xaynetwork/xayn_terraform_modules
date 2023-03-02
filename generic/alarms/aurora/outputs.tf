output "arns" {
  description = "ARNs of the CloudWatch alarms."
  value = {
    read_latency  = try(module.read_latency.cloudwatch_metric_alarm_arn, "")
    write_latency = try(module.write_latency.cloudwatch_metric_alarm_arn, "")
  }
}
