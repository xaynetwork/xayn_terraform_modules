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
    name     = "ip-rate-limit"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.ip_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ip-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "users"
    priority = 2

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
      metric_name                = "users"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "documents"
    priority = 3

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
      metric_name                = "documents"
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
