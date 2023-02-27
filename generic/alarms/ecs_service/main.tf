locals {
  cpu_usage_threshold = lookup(var.cpu_usage, "threshold", 90)
  log_error_threshold = lookup(var.log_error, "threshold", 250)
}

module "cpu_usage" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = lookup(var.cpu_usage, "create_alarm", true)
  alarm_name          = "${var.prefix}${var.service_name}_cpu_usage"
  alarm_description   = "High CPU usage for ${var.service_name}. It may indicate that the auto scaling reach its maximum."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = var.cpu_usage_threshold

  metric_query = [{
    id          = "e1"
    expression  = "m1 * 100 / m2"
    label       = "cpu_into_percentage"
    return_data = "true"
    }, {
    id         = "m1"
    account_id = var.account_id

    metric = [{
      namespace   = "ECS/ContainerInsights"
      metric_name = "CpuUtilized"
      period      = 60
      stat        = "Sum"

      dimensions = {
        ClusterName = var.cluster_name
        ServiceName = var.service_name
      }
    }]
    }, {
    id         = "m2"
    account_id = var.account_id

    metric = [{
      namespace   = "ECS/ContainerInsights"
      metric_name = "CpuReserved"
      period      = 60
      stat        = "Sum"

      dimensions = {
        ClusterName = var.cluster_name
        ServiceName = var.service_name
      }
    }]
  }]

  actions_enabled = lookup(var.cpu_usage, "actions_enabled", true)
  alarm_actions   = lookup(var.cpu_usage, "alarm_actions", [])
  ok_actions      = lookup(var.cpu_usage, "ok_actions", [])

  tags = var.tags
}

module "log_error_filter" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-metric-filter"
  version = "4.2.1"

  create_metric_alarm = lookup(var.log_error, "create_alarm", true)
  log_group_name      = module.service.log_group_name

  name    = "${var.service_name}_error_metric"
  pattern = lookup(var.log_error, "log_pattern", "ERROR")

  metric_transformation_namespace = "${var.cluster_name}/${var.service_name}"
  metric_transformation_name      = "ErrorCount"
}

module "log_error" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = lookup(var.log_error, "create_alarm", true)
  alarm_name          = "${var.prefix}${var.service_name}_log_errors"
  alarm_description   = "Number of errors in ${var.service_name} > ${var.log_error_threshold}."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.log_error_threshold
  treat_missing_data  = "notBreaching"

  metric_query = [{
    id          = "m1"
    account_id  = var.account_id
    return_data = true

    metric = [{
      namespace   = "${var.cluster_name}/${var.service_name}"
      metric_name = "ErrorCount"
      period      = 60
      stat        = "Sum"
    }]
    }
  ]

  actions_enabled = lookup(var.log_error, "actions_enabled", true)
  alarm_actions   = lookup(var.log_error, "alarm_actions", [])
  ok_actions      = lookup(var.log_error, "ok_actions", [])

  tags = var.tags
}
