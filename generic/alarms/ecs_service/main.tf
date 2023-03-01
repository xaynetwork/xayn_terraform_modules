locals {
  defaults = {
    create_alarm    = true
    actions_enabled = true
    ok_actions      = []
    alarm_actions   = []
  }

  cpu_usage_conf = merge(local.defaults, { threshold = 90 }, var.cpu_usage)
  log_error_conf = merge(local.defaults, { threshold = 250, log_pattern = "ERROR" }, var.log_error)
}

module "cpu_usage" {
  providers = {
    aws = aws.monitoring-account
  }

  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = local.cpu_usage_conf.create_alarm
  alarm_name          = "${var.prefix}${var.service_name}_cpu_usage"
  alarm_description   = "High CPU usage for ${var.service_name}. It may indicate that the auto scaling reach its maximum."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = local.cpu_usage_conf.threshold

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

  actions_enabled = local.cpu_usage_conf.actions_enabled
  alarm_actions   = local.cpu_usage_conf.alarm_actions
  ok_actions      = local.cpu_usage_conf.ok_actions

  tags = var.tags
}

module "log_error_filter" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-metric-filter"
  version = "4.2.1"

  create_cloudwatch_log_metric_filter = local.log_error_conf.create_alarm
  log_group_name                      = var.log_group_name

  name    = "${var.service_name}_error_metric"
  pattern = local.log_error_conf.log_pattern

  metric_transformation_namespace = "${var.cluster_name}/${var.service_name}"
  metric_transformation_name      = "ErrorCount"
}

module "log_error" {
  providers = {
    aws = aws.monitoring-account
  }

  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = local.log_error_conf.create_alarm
  alarm_name          = "${var.prefix}${var.service_name}_log_errors"
  alarm_description   = "Number of errors in ${var.service_name} > ${local.log_error_conf.threshold}."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = local.log_error_conf.threshold
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

  actions_enabled = local.log_error_conf.actions_enabled
  alarm_actions   = local.log_error_conf.alarm_actions
  ok_actions      = local.log_error_conf.ok_actions

  tags = var.tags
}
