locals {
  defaults = {
    create_alarm    = true
    actions_enabled = true
    ok_actions      = []
    alarm_actions   = []
  }

  all_requests_conf         = merge(local.defaults, { threshold = 40000 }, var.all_requests)
  all_blocked_requests_conf = merge(local.defaults, { threshold = 5000 }, var.all_blocked_requests)
  ip_rate_limit_conf        = merge(local.defaults, { threshold = 0 }, var.ip_rate_limit)
}

module "all_requests" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = local.all_requests_conf.create_alarm
  alarm_name          = "${var.prefix}waf_all_requests"
  alarm_description   = "High traffic load on ${var.web_acl_region} ${var.web_acl_name}. Number of WAF ALL requests > ${local.all_requests_conf.threshold}."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = local.all_requests_conf.threshold
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
        Region = var.web_acl_region
        Rule   = "ALL"
      }
    }]
    }
  ]

  actions_enabled = local.all_requests_conf.actions_enabled
  alarm_actions   = local.all_requests_conf.alarm_actions
  ok_actions      = local.all_requests_conf.ok_actions

  tags = var.tags
}

module "all_requests_blocked" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = local.all_blocked_requests_conf.create_alarm
  alarm_name          = "${var.prefix}waf_all_blocked_requests"
  alarm_description   = "Number of ${var.web_acl_region} ${var.web_acl_name} ALL blocked requests > ${local.all_blocked_requests_conf.threshold}. It may indicate a DDoS attack or a proxy."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = local.all_blocked_requests_conf.threshold
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
        Region = var.web_acl_region
        Rule   = "ALL"
      }
    }]
    }
  ]

  actions_enabled = local.all_blocked_requests_conf.actions_enabled
  alarm_actions   = local.all_blocked_requests_conf.alarm_actions
  ok_actions      = local.all_blocked_requests_conf.ok_actions

  tags = var.tags
}

module "ip_rate_limit" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = local.ip_rate_limit_conf.create_alarm
  alarm_name          = "${var.prefix}waf_ip_rate_limit"
  alarm_description   = "An IP hit the ${var.web_acl_region} ${var.web_acl_name} IP rate limit. It may indicate a DDoS attack or a proxy."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = local.ip_rate_limit_conf.threshold
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
        Region = var.web_acl_region
        Rule   = "block-ip-hit-rate-limit"
      }
    }]
    }
  ]

  actions_enabled = local.ip_rate_limit_conf.actions_enabled
  alarm_actions   = local.ip_rate_limit_conf.alarm_actions
  ok_actions      = local.ip_rate_limit_conf.ok_actions

  tags = var.tags
}
