locals {
  defaults = {
    create_alarm    = true
    actions_enabled = true
    ok_actions      = []
    alarm_actions   = []
  }

  error_rate_conf        = merge(local.defaults, { threshold = 1 }, var.error_rate)
  http_5xx_error_conf    = merge(local.defaults, { threshold = 0 }, var.http_5xx_error)
  latency_conf           = merge(local.defaults, { threshold = 100 }, var.latency)
  latency_by_method_conf = merge(local.defaults, { threshold = 100, method = "POST", resource = "/{proxy+}" }, var.latency_by_method)
}

module "http_5xx_error" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = local.http_5xx_error_conf.create_alarm
  alarm_name          = "${var.prefix}${var.api_name}_api_gateway_5xx_error"
  alarm_description   = "Number of HTTP-5XX errors > ${local.http_5xx_error_conf.threshold} for ${var.api_name}. It may indicate an issue within the NLB integration or with the lambda authorizer."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = local.http_5xx_error_conf.threshold
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
        ApiName = var.api_name
        Stage   = var.api_stage
      }
    }]
    }
  ]

  actions_enabled = local.http_5xx_error_conf.actions_enabled
  alarm_actions   = local.http_5xx_error_conf.alarm_actions
  ok_actions      = local.http_5xx_error_conf.ok_actions

  tags = var.tags
}

module "latency" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = local.latency_conf.create_alarm
  alarm_name          = "${var.prefix}${var.api_name}_api_gateway_latency"
  alarm_description   = "High latency for ${var.api_name}. P90 latency > ${local.latency_conf.threshold}ms"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 10
  threshold           = local.latency_conf.threshold
  treat_missing_data  = "notBreaching"

  metric_query = [{
    id          = "m1"
    account_id  = var.account_id
    return_data = true

    metric = [{
      namespace   = "AWS/ApiGateway"
      metric_name = "Latency"
      period      = 60
      stat        = "p90"
      dimensions = {
        ApiName = var.api_name
        Stage   = var.api_stage
      }
    }]
    }
  ]

  actions_enabled = local.latency_conf.actions_enabled
  alarm_actions   = local.latency_conf.alarm_actions
  ok_actions      = local.latency_conf.ok_actions

  tags = var.tags
}

module "latency_by_method" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = local.latency_by_method_conf.create_alarm
  alarm_name          = "${var.prefix}${var.api_name}_api_gateway_latency_by_method"
  alarm_description   = "High latency for ${var.api_name} ${local.latency_by_method_conf.method} ${local.latency_by_method_conf.resource}. P90 latency > ${local.latency_by_method_conf.threshold}ms"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 10
  threshold           = local.latency_by_method_conf.threshold
  treat_missing_data  = "notBreaching"

  metric_query = [{
    id          = "m1"
    account_id  = var.account_id
    return_data = true

    metric = [{
      namespace   = "AWS/ApiGateway"
      metric_name = "Latency"
      period      = 60
      stat        = "p90"
      dimensions = {
        ApiName  = var.api_name
        Stage    = var.api_stage
        Method   = local.latency_by_method_conf.method
        Resource = local.latency_by_method_conf.resource
      }
    }]
    }
  ]

  actions_enabled = local.latency_by_method_conf.actions_enabled
  alarm_actions   = local.latency_by_method_conf.alarm_actions
  ok_actions      = local.latency_by_method_conf.ok_actions

  tags = var.tags
}

module "error_rate" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = local.error_rate_conf.create_alarm
  alarm_name          = "${var.prefix}${var.api_name}_api_gateway_error_rate"
  alarm_description   = "Error rate above ${local.error_rate_conf.threshold}% for ${var.api_name}."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = local.error_rate_conf.threshold
  treat_missing_data  = "notBreaching"

  metric_query = [{
    id          = "e1"
    expression  = "100 * (m2 / m1)"
    label       = "error_rate"
    return_data = "true"
    }, {
    id         = "m1"
    account_id = var.account_id

    metric = [{
      namespace   = "AWS/ApiGateway"
      metric_name = "Count"
      period      = 60
      stat        = "Sum"

      dimensions = {
        ApiName = var.api_name
        Stage   = var.api_stage
      }
    }]
    }, {
    id         = "m2"
    account_id = var.account_id

    metric = [{
      namespace   = "AWS/ApiGateway"
      metric_name = "5XXError"
      period      = 60
      stat        = "Sum"

      dimensions = {
        ApiName = var.api_name
        Stage   = var.api_stage
      }
    }]
  }]

  actions_enabled = local.error_rate_conf.actions_enabled
  alarm_actions   = local.error_rate_conf.alarm_actions
  ok_actions      = local.error_rate_conf.ok_actions

  tags = var.tags
}
