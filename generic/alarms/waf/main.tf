locals {
  all_requests_threshold         = lookup(var.all_requests, "threshold", 40000)
  all_blocked_requests_threshold = lookup(var.all_blocked_requests, "threshold", 5000)
  ip_rate_limit_threshold        = lookup(var.ip_rate_limit, "threshold", 0)
}

module "all_requests" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = lookup(var.all_requests, "create_alarm", true)
  alarm_name          = "${var.prefix}waf_all_requests"
  alarm_description   = "High traffic load on WAF. Number of WAF ALL requests > ${local.all_requests_threshold}."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = local.all_requests_threshold
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

  actions_enabled = lookup(var.all_requests, "actions_enabled", true)
  alarm_actions   = lookup(var.all_requests, "alarm_actions", [])
  ok_actions      = lookup(var.all_requests, "ok_actions", [])

  tags = var.tags
}

module "all_requests_blocked" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = lookup(var.all_blocked_requests, "create_alarm", true)
  alarm_name          = "${var.prefix}waf_all_blocked_requests"
  alarm_description   = "Number of WAF ALL blocked requests > ${local.all_blocked_requests_threshold}. It may indicate a DDoS attack or a proxy."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = local.all_blocked_requests_threshold
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

  actions_enabled = lookup(var.all_blocked_requests, "actions_enabled", true)
  alarm_actions   = lookup(var.all_blocked_requests, "alarm_actions", [])
  ok_actions      = lookup(var.all_blocked_requests, "ok_actions", [])

  tags = var.tags
}

module "ip_rate_limit" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = lookup(var.ip_rate_limit, "create_alarm", true)
  alarm_name          = "${var.prefix}waf_ip_rate_limit"
  alarm_description   = "An IP hit the WAF IP rate limit. It may indicate a DDoS attack or a proxy."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = local.ip_rate_limit_threshold
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

  actions_enabled = lookup(var.ip_rate_limit, "actions_enabled", true)
  alarm_actions   = lookup(var.ip_rate_limit, "alarm_actions", [])
  ok_actions      = lookup(var.ip_rate_limit, "ok_actions", [])

  tags = var.tags
}
