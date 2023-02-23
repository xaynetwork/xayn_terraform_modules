module "services_http_5xx_error_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = var.create_alarms
  alarm_name          = "alb_services_5xx_error"
  alarm_description   = "Number of ALB services HTTP-5XX errors > ${var.services_http_5xx_error_threshold}. It may indicate an issue within the ECS services."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.services_http_5xx_error_threshold
  period              = 60
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_5XX_Count"
  statistic   = "Sum"

  dimensions = {
    LoadBalancer = var.lb_arn_suffix
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

module "http_5xx_error_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = var.create_alarms
  alarm_name          = "alb_5xx_error"
  alarm_description   = "Number of ALB HTTP-5XX errors > ${var.http_5xx_error_threshold}. It may indicate an integration issue with the ECS services."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.http_5xx_error_threshold
  period              = 60
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_5XX_Count"
  statistic   = "Sum"

  dimensions = {
    LoadBalancer = var.lb_arn_suffix
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

module "http_4xx_error_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = var.create_alarms
  alarm_name          = "alb_4xx_error"
  alarm_description   = "Number of ALB HTTP-4XX errors > ${var.http_4xx_error_threshold}. It may indicate an integration issue with the NLB or with the ECS services."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.http_4xx_error_threshold
  period              = 60
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_4XX_Count"
  statistic   = "Sum"

  dimensions = {
    LoadBalancer = var.lb_arn_suffix
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}
