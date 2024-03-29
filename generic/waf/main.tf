resource "aws_wafv2_ip_set" "blacklist" {
  name               = "${var.name}-blacklist"
  description        = "B2b API Gateway blacklist of IP addresses"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.blacklist

  tags = var.tags
}

resource "aws_wafv2_ip_set" "whitelist" {
  name               = "${var.name}-whitelist"
  description        = "B2b API Gateway whitelist of IP addresses"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.whitelist

  tags = var.tags
}

resource "aws_wafv2_web_acl" "api_gateway" {
  name        = var.name
  description = "WAF with basic rules"
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
    name     = "block-overload"
    priority = 50

    action {
      block {}
    }

    statement {
      or_statement {
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
              type     = "NONE"
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
              type     = "NONE"
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

# CloudWatch alarms
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "alarms" {
  providers = {
    aws = aws.monitoring-account
  }
  source = "../alarms/waf"

  account_id = data.aws_caller_identity.current.account_id
  prefix     = "${data.aws_caller_identity.current.account_id}_"

  web_acl_name   = aws_wafv2_web_acl.api_gateway.name
  web_acl_region = data.aws_region.current.name

  all_requests_blocked = var.alarm_all_requests_blocked
  ip_rate_limit        = var.alarm_ip_rate_limit

  tags = var.tags
}
