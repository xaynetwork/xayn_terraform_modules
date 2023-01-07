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
    name     = "users-path"
    priority = 50

    action {
      allow {}
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

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "users-path"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "documents-path"
    priority = 60

    action {
      allow {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          uri_path {}
        }

        search_string         = "/default/documents"
        positional_constraint = "STARTS_WITH"
        text_transformation {
          type     = "URL_DECODE"
          priority = 1
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "documents-path"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "all"
    sampled_requests_enabled   = true
  }

  tags = var.tags
}
