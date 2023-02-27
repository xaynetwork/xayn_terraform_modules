locals {
  http_5xx_error_threshold      = lookup(var.http_5xx_error, "threshold", 0)
  integration_latency_threshold = lookup(var.integration_latency, "threshold", 250)
  latency_threshold             = lookup(var.latency, "threshold", 300)
}

module "http_5xx_error" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = lookup(var.http_5xx_error, "create_alarm", true)
  alarm_name          = "${var.prefix}api_gateway_5xx_error_${var.tenant}"
  alarm_description   = "Number of API Gateway HTTP-5XX errors > ${var.http_5xx_error_threshold} for tenant ${var.tenant}. It may indicate an issue within the NLB integration or with the lambda authorizer."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.http_5xx_error_threshold
  treat_missing_data  = "notBreaching"

  metric_query = [{
    id          = "m1"
    account_id  = var.account_id
    return_data = true

    metric = [{
      namespace   = "AWS/ApiGateway"
      metric_name = "5XXError"
      period      = 60
      stat        = "Sum"
      dimensions = {
        ApiName = local.api_name
        Stage   = "default"
      }
    }]
    }
  ]

  actions_enabled = lookup(var.http_5xx_error, "actions_enabled", true)
  alarm_actions   = lookup(var.http_5xx_error, "alarm_actions", [])
  ok_actions      = lookup(var.http_5xx_error, "ok_actions", [])

  tags = var.tags
}

module "integration_latency" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = lookup(var.integration_latency, "create_alarm", true)
  alarm_name          = "${var.prefix}api_gateway_integration_latency_${var.tenant}"
  alarm_description   = "High API Gateway integration latency for tenant ${var.tenant}. Average integration latency > ${var.integration_latency_threshold}ms"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = var.integration_latency_threshold
  treat_missing_data  = "notBreaching"

  metric_query = [{
    id          = "m1"
    account_id  = var.account_id
    return_data = true

    metric = [{
      namespace   = "AWS/ApiGateway"
      metric_name = "IntegrationLatency"
      period      = 60
      stat        = "Average"
      dimensions = {
        ApiName = local.api_name
        Stage   = "default"
      }
    }]
    }
  ]

  actions_enabled = lookup(var.integration_latency, "actions_enabled", true)
  alarm_actions   = lookup(var.integration_latency, "alarm_actions", [])
  ok_actions      = lookup(var.integration_latency, "ok_actions", [])

  tags = var.tags
}

module "latency" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = lookup(var.latency, "create_alarm", true)
  alarm_name          = "${var.prefix}api_gateway_latency_${var.tenant}"
  alarm_description   = "High API Gateway latency for tenant ${var.tenant}. Average latency > ${var.latency_threshold}ms"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = var.latency_threshold
  treat_missing_data  = "notBreaching"

  metric_query = [{
    id          = "m1"
    account_id  = var.account_id
    return_data = true

    metric = [{
      namespace   = "AWS/ApiGateway"
      metric_name = "Latency"
      period      = 60
      stat        = "Average"
      dimensions = {
        ApiName = local.api_name
        Stage   = "default"
      }
    }]
    }
  ]

  actions_enabled = lookup(var.latency, "actions_enabled", true)
  alarm_actions   = lookup(var.latency, "alarm_actions", [])
  ok_actions      = lookup(var.latency, "ok_actions", [])

  tags = var.tags
}
