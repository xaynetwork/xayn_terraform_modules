data "aws_region" "current" {}

resource "aws_kms_key" "this" {
  description = "KMS key for Slack URL"
}

resource "aws_kms_ciphertext" "slack_url" {
  plaintext = var.slack_url
  key_id    = aws_kms_key.this.arn
}

module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "5.5.0"

  sns_topic_name = "slack-alarm-notification"

  slack_webhook_url = aws_kms_ciphertext.slack_url.ciphertext_blob
  slack_channel     = "aws-notification"
  slack_username    = "reporter"

  kms_key_arn = aws_kms_key.this.arn

  lambda_description = "Lambda function which sends notifications to Slack"

  cloudwatch_log_group_tags = var.tags
  sns_topic_tags            = var.tags
  lambda_function_tags      = var.tags
  tags                      = var.tags
}

module "alb_services_5xx_error_alarm" {
  count   = var.create_alb_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "alb_services_5xx_error"
  alarm_description   = "Number of ALB services HTTP-5XX errors > ${var.alb_services_5xx_error_threshold}. It may indicate an issue within the ECS services."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.alb_services_5xx_error_threshold
  period              = 60

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_5XX_Count"
  statistic   = "Sum"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [module.notify_slack.slack_topic_arn]
  ok_actions    = [module.notify_slack.slack_topic_arn]

  tags = var.tags
}

module "alb_5xx_error_alarm" {
  count   = var.create_alb_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "alb_5xx_error"
  alarm_description   = "Number of ALB HTTP-5XX errors > ${var.alb_5xx_error_threshold}. It may indicate an integration issue with the ECS services."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.alb_5xx_error_threshold
  period              = 60

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_5XX_Count"
  statistic   = "Sum"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [module.notify_slack.slack_topic_arn]
  ok_actions    = [module.notify_slack.slack_topic_arn]

  tags = var.tags
}

module "alb_4xx_error_alarm" {
  count   = var.create_alb_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "alb_4xx_error"
  alarm_description   = "Number of ALB HTTP-4XX errors > ${var.alb_4xx_error_threshold}. It may indicate an integration issue with the NLB or with the ECS services."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.alb_4xx_error_threshold
  period              = 60

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_4XX_Count"
  statistic   = "Sum"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [module.notify_slack.slack_topic_arn]
  ok_actions    = [module.notify_slack.slack_topic_arn]

  tags = var.tags
}

module "waf_all_requests_alarm" {
  count   = var.create_waf_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "waf_all_requests"
  alarm_description   = "High traffic load on the WAF. Number of WAF ALL requests > ${var.waf_all_requests_threshold}."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = var.waf_all_requests_threshold
  period              = 60

  namespace   = "AWS/WAFV2"
  metric_name = "CountedRequests"
  statistic   = "Sum"

  dimensions = {
    WebACL = var.web_acl
    Region = data.aws_region.current.name
    Rule   = "ALL"
  }

  alarm_actions = [module.notify_slack.slack_topic_arn]
  ok_actions    = [module.notify_slack.slack_topic_arn]

  tags = var.tags
}

module "waf_all_requests_blocked_alarm" {
  count   = var.create_waf_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "waf_all_blocked_requests"
  alarm_description   = "Number of WAF ALL blocked requests > ${var.waf_all_blocked_requests_threshold}. It may indicate a DDOS attack or a proxy."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.waf_all_blocked_requests_threshold
  period              = 60

  namespace   = "AWS/WAFV2"
  metric_name = "BlockedRequests"
  statistic   = "Sum"

  dimensions = {
    WebACL = var.web_acl
    Region = data.aws_region.current.name
    Rule   = "ALL"
  }

  alarm_actions = [module.notify_slack.slack_topic_arn]
  ok_actions    = [module.notify_slack.slack_topic_arn]

  tags = var.tags
}

module "waf_ip_rate_limit_alarm" {
  count   = var.create_waf_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "waf_ip_rate_limit"
  alarm_description   = "An IP hit the WAF IP rate limit. It may indicate a DDOS attack or a proxy."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.waf_ip_rate_limit_threshold
  period              = 60

  namespace   = "AWS/WAFV2"
  metric_name = "BlockedRequests"
  statistic   = "Sum"

  dimensions = {
    WebACL = var.web_acl
    Region = data.aws_region.current.name
    Rule   = "block-ip-hit-rate-limit"
  }

  alarm_actions = [module.notify_slack.slack_topic_arn]
  ok_actions    = [module.notify_slack.slack_topic_arn]

  tags = var.tags
}

module "aurora_read_latency_alarm" {
  count   = var.create_aurora_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "aurora_read_latency"
  alarm_description   = "High Aurora read latency > ${var.aurora_read_latency_threshold}ms. It may indicate slow queries."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.aurora_read_latency_threshold

  metric_query {
    id          = "e1"
    expression  = "m1*1000"
    label       = "latency_into_milliseconds"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      namespace   = "AWS/RDS"
      metric_name = "ReadLatency"
      period      = 60
      stat        = "Average"

      dimensions = {
        DBClusterIdentifier = var.aurora_cluster_name
      }
    }
  }

  alarm_actions = [module.notify_slack.slack_topic_arn]
  ok_actions    = [module.notify_slack.slack_topic_arn]

  tags = var.tags
}

module "aurora_write_latency_alarm" {
  count   = var.create_aurora_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "aurora_write_latency"
  alarm_description   = "High Aurora write latency > ${var.aurora_write_latency_threshold}ms. It may indicate slow queries."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.aurora_write_latency_threshold

  metric_query {
    id          = "e1"
    expression  = "m1*1000"
    label       = "latency_into_milliseconds"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      namespace   = "AWS/RDS"
      metric_name = "WriteLatency"
      period      = 60
      stat        = "Average"

      dimensions = {
        DBClusterIdentifier = var.aurora_cluster_name
      }
    }
  }

  alarm_actions = [module.notify_slack.slack_topic_arn]
  ok_actions    = [module.notify_slack.slack_topic_arn]

  tags = var.tags
}
