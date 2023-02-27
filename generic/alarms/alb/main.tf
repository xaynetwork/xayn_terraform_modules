locals {
  services_http_5xx_error_threshold = lookup(var.services_http_5xx_error, "threshold", 0)
  http_5xx_error_threshold          = lookup(var.http_5xx_error, "threshold", 0)
  http_4xx_error_threshold          = lookup(var.http_4xx_error, "threshold", 0)
}

module "services_http_5xx_error" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = lookup(var.services_http_5xx_error, "create_alarm", true)
  alarm_name          = "${var.prefix}alb_services_5xx_error"
  alarm_description   = "Number of ALB services HTTP-5XX errors > ${local.services_http_5xx_error_threshold}. It may indicate an issue within the ECS services."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = local.services_http_5xx_error_threshold
  treat_missing_data  = "notBreaching"

  metric_query = [{
    id          = "m1"
    account_id  = var.account_id
    return_data = true

    metric = [{
      namespace   = "AWS/ApplicationELB"
      metric_name = "HTTPCode_Target_5XX_Count"
      period      = 60
      stat        = "Sum"
      dimensions = {
        LoadBalancer = var.arn_suffix
      }
    }]
    }
  ]

  actions_enabled = lookup(var.services_http_5xx_error, "actions_enabled", true)
  alarm_actions   = lookup(var.services_http_5xx_error, "alarm_actions", null)
  ok_actions      = lookup(var.services_http_5xx_error, "ok_actions", null)

  tags = var.tags
}

module "http_5xx_error" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = lookup(var.http_5xx_error, "create_alarm", true)
  alarm_name          = "${var.prefix}alb_5xx_error"
  alarm_description   = "Number of ALB HTTP-5XX errors > ${local.http_5xx_error_threshold}. It may indicate an integration issue with the ECS services."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = local.http_5xx_error_threshold
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

  actions_enabled = lookup(var.http_5xx_error, "actions_enabled", true)
  alarm_actions   = lookup(var.http_5xx_error, "alarm_actions", null)
  ok_actions      = lookup(var.http_5xx_error, "ok_actions", null)

  tags = var.tags
}

module "http_4xx_error" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = lookup(var.http_4xx_error, "create_alarm", true)
  alarm_name          = "${var.prefix}alb_4xx_error"
  alarm_description   = "Number of ALB HTTP-4XX errors > ${local.http_4xx_error_threshold}. It may indicate an integration issue with the NLB or with the ECS services."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = local.http_4xx_error_threshold
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

  actions_enabled = lookup(var.http_4xx_error, "actions_enabled", true)
  alarm_actions   = lookup(var.http_4xx_error, "alarm_actions", null)
  ok_actions      = lookup(var.http_4xx_error, "ok_actions", null)

  tags = var.tags
}
