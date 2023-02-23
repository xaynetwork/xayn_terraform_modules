data "aws_region" "current" {}

module "all_requests_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = var.create_alarms
  alarm_name          = "waf_all_requests"
  alarm_description   = "High traffic load on WAF. Number of WAF ALL requests > ${var.all_requests_threshold}."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = var.all_requests_threshold
  treat_missing_data  = "notBreaching"

  metric_query = [{
    id          = "m1"
    account_id  = var.account_id
    return_data = true

    metric = [{
      namespace   = "AWS/WAFV2"
      metric_name = "CountedRequests"
      period      = 60
      stat        = "Sum"
      dimensions = {
        WebACL = var.web_acl_name
        Region = data.aws_region.current.name
        Rule   = "ALL"
      }
    }]
    }
  ]

  actions_enabled = var.actions_enabled
  alarm_actions   = [var.sns_topic_arn]
  ok_actions      = [var.sns_topic_arn]

  tags = var.tags
}

module "all_requests_blocked_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = var.create_alarms
  alarm_name          = "waf_all_blocked_requests"
  alarm_description   = "Number of WAF ALL blocked requests > ${var.all_blocked_requests_threshold}. It may indicate a DDoS attack or a proxy."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.all_blocked_requests_threshold
  treat_missing_data  = "notBreaching"

  metric_query = [{
    id          = "m1"
    account_id  = var.account_id
    return_data = true

    metric = [{
      namespace   = "AWS/WAFV2"
      metric_name = "BlockedRequests"
      period      = 60
      stat        = "Sum"
      dimensions = {
        WebACL = var.web_acl_name
        Region = data.aws_region.current.name
        Rule   = "ALL"
      }
    }]
    }
  ]

  actions_enabled = var.actions_enabled
  alarm_actions   = [var.sns_topic_arn]
  ok_actions      = [var.sns_topic_arn]

  tags = var.tags
}

module "ip_rate_limit_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = var.create_alarms
  alarm_name          = "waf_ip_rate_limit"
  alarm_description   = "An IP hit the WAF IP rate limit. It may indicate a DDoS attack or a proxy."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.ip_rate_limit_threshold
  treat_missing_data  = "notBreaching"

  metric_query = [{
    id          = "m1"
    account_id  = var.account_id
    return_data = true

    metric = [{
      namespace   = "AWS/WAFV2"
      metric_name = "BlockedRequests"
      period      = 60
      stat        = "Sum"
      dimensions = {
        WebACL = var.web_acl_name
        Region = data.aws_region.current.name
        Rule   = "block-ip-hit-rate-limit"
      }
    }]
    }
  ]

  actions_enabled = var.actions_enabled
  alarm_actions   = [var.sns_topic_arn]
  ok_actions      = [var.sns_topic_arn]

  tags = var.tags
}
