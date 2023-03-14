locals {
  defaults = {
    create_alarm    = true
    actions_enabled = true
    ok_actions      = []
    alarm_actions   = []
    threshold       = 0
  }

  http_5xx_error_conf = merge(local.defaults, var.http_5xx_error)
  http_4xx_error_conf = merge(local.defaults, var.http_4xx_error)
}

module "http_5xx_error" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = local.http_5xx_error_conf.create_alarm
  alarm_name          = "${var.prefix}alb_5xx_error"
  alarm_description   = "Number of ALB HTTP-5XX errors > ${local.http_5xx_error_conf.threshold}. It may indicate an integration issue with the ECS services."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = local.http_5xx_error_conf.threshold
  treat_missing_data  = "notBreaching"

  metric_query = [{
    id          = "m1"
    account_id  = var.account_id
    return_data = true

    metric = [{
      namespace   = "AWS/ApplicationELB"
      metric_name = "HTTPCode_ELB_5XX_Count"
      period      = 60
      stat        = "Sum"
      dimensions = {
        LoadBalancer = var.arn_suffix
      }
    }]
    }
  ]

  actions_enabled = local.http_5xx_error_conf.actions_enabled
  alarm_actions   = local.http_5xx_error_conf.alarm_actions
  ok_actions      = local.http_5xx_error_conf.ok_actions

  tags = var.tags
}

module "http_4xx_error" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = local.http_4xx_error_conf.create_alarm
  alarm_name          = "${var.prefix}alb_4xx_error"
  alarm_description   = "Number of ALB HTTP-4XX errors > ${local.http_4xx_error_conf.threshold}. It may indicate an integration issue with the NLB or with the ECS services."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = local.http_4xx_error_conf.threshold
  treat_missing_data  = "notBreaching"

  metric_query = [{
    id          = "m1"
    account_id  = var.account_id
    return_data = true

    metric = [{
      namespace   = "AWS/ApplicationELB"
      metric_name = "HTTPCode_ELB_4XX_Count"
      period      = 60
      stat        = "Sum"
      dimensions = {
        LoadBalancer = var.arn_suffix
      }
    }]
    }
  ]

  actions_enabled = local.http_4xx_error_conf.actions_enabled
  alarm_actions   = local.http_4xx_error_conf.alarm_actions
  ok_actions      = local.http_4xx_error_conf.ok_actions

  tags = var.tags
}
