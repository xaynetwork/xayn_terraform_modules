data "aws_region" "current" {}

resource "aws_wafv2_ip_set" "blacklist" {
  name               = "b2b-api-gateway-blacklist"
  description        = "B2b API Gateway blacklist of IP addresses"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.blacklist

  tags = var.tags
}

resource "aws_wafv2_ip_set" "whitelist" {
  name               = "b2b-api-gateway-whitelist"
  description        = "B2b API Gateway whitelist of IP addresses"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.whitelist

  tags = var.tags
}

resource "aws_wafv2_web_acl" "api_gateway" {
  name        = "b2b-api-gateway-basic-protection"
  description = "Basic ACL for the b2b API Gateway"
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 0

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "bad-actors"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "ip-blacklist"
    priority = 10

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blacklist.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ip-blacklist"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "ip-rate-limit"
    priority = 20

    action {
      count {}
    }

    statement {
      rate_based_statement {
        limit              = var.ip_rate_limit
        aggregate_key_type = "IP"
      }
    }

    rule_label {
      name = "api-gateway:ip-rate-limit"
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ip-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "ip-whitelist"
    priority = 30

    action {
      count {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.whitelist.arn
      }
    }

    rule_label {
      name = "api-gateway:whitelist"
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ip-whitelist"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "block-ip-hit-rate-limit"
    priority = 40

    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          label_match_statement {
            scope = "LABEL"
            key   = "api-gateway:ip-rate-limit"
          }
        }

        statement {
          not_statement {
            statement {
              label_match_statement {
                scope = "LABEL"
                key   = "api-gateway:whitelist"
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "block-ip-hit-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "block-overload-body"
    priority = 45

    action {
      count {}
    }

    statement {
      and_statement {
        statement {
          size_constraint_statement {
            comparison_operator = "GT"
            size                = var.user_body_size
            field_to_match {
              body {}
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
          }
        }

        statement {
          byte_match_statement {
            field_to_match {
              uri_path {}
            }
            search_string         = "/default/users"
            positional_constraint = "STARTS_WITH"
            text_transformation {
              type     = "URL_DECODE"
              priority = 1
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "block-overload"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "block-overload"
    priority = 55

    action {
      count {}
    }

    statement {
      or_statement {
        statement {
          size_constraint_statement {
            comparison_operator = "GT"
            size                = var.doc_body_size
            field_to_match {
              body {}
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
          }
        }

        statement {
          size_constraint_statement {
            comparison_operator = "GT"
            size                = var.headers_size
            field_to_match {
              headers {
                match_pattern {
                  all {}
                }
                match_scope       = "VALUE"
                oversize_handling = "MATCH"
              }
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
          }
        }

        statement {
          size_constraint_statement {
            comparison_operator = "GT"
            size                = var.query_size
            field_to_match {
              all_query_arguments {}
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "block-overload"
      sampled_requests_enabled   = true
    }
  }

  dynamic "rule" {
    for_each = var.path_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        allow {}
      }

      statement {
        byte_match_statement {
          field_to_match {
            uri_path {}
          }

          search_string         = rule.value.url_segment
          positional_constraint = "STARTS_WITH"
          text_transformation {
            type     = "URL_DECODE"
            priority = 1
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "all"
    sampled_requests_enabled   = true
  }

  tags = var.tags
}

# cloudwatch alarms
module "all_requests_alarm" {
  count   = var.create_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "waf_all_requests"
  alarm_description   = "High traffic load on WAF. Number of WAF ALL requests > ${var.all_requests_threshold}."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = var.all_requests_threshold
  period              = 60
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/WAFV2"
  metric_name = "CountedRequests"
  statistic   = "Sum"

  dimensions = {
    WebACL = aws_wafv2_web_acl.api_gateway.name
    Region = data.aws_region.current.name
    Rule   = "ALL"
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

module "all_requests_blocked_alarm" {
  count   = var.create_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "waf_all_blocked_requests"
  alarm_description   = "Number of WAF ALL blocked requests > ${var.all_blocked_requests_threshold}. It may indicate a DDoS attack or a proxy."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.all_blocked_requests_threshold
  period              = 60
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/WAFV2"
  metric_name = "BlockedRequests"
  statistic   = "Sum"

  dimensions = {
    WebACL = aws_wafv2_web_acl.api_gateway.name
    Region = data.aws_region.current.name
    Rule   = "ALL"
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

module "ip_rate_limit_alarm" {
  count   = var.create_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "waf_ip_rate_limit"
  alarm_description   = "An IP hit the WAF IP rate limit. It may indicate a DDoS attack or a proxy."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.ip_rate_limit_threshold
  period              = 60
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/WAFV2"
  metric_name = "BlockedRequests"
  statistic   = "Sum"

  dimensions = {
    WebACL = aws_wafv2_web_acl.api_gateway.name
    Region = data.aws_region.current.name
    Rule   = "block-ip-hit-rate-limit"
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}
