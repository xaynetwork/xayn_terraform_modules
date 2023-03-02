locals {
  defaults = {
    create_alarm    = true
    actions_enabled = true
    ok_actions      = []
    alarm_actions   = []
    threshold       = 10
  }

  read_latency_conf  = merge(local.defaults, var.read_latency)
  write_latency_conf = merge(local.defaults, var.write_latency)
}

module "read_latency" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = local.read_latency_conf.create_alarm
  alarm_name          = "${var.prefix}aurora_read_latency"
  alarm_description   = "High average Aurora read latency > ${local.read_latency_conf.threshold}ms. It may indicate slow queries."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = local.read_latency_conf.threshold

  metric_query = [{
    id          = "e1"
    expression  = "m1 * 1000"
    label       = "latency_into_milliseconds"
    return_data = "true"
    }, {
    id         = "m1"
    account_id = var.account_id

    metric = [{
      namespace   = "AWS/RDS"
      metric_name = "ReadLatency"
      period      = 60
      stat        = "Average"

      dimensions = {
        DBClusterIdentifier = var.db_cluster_identifier
      }
    }]
  }]

  actions_enabled = local.read_latency_conf.actions_enabled
  alarm_actions   = local.read_latency_conf.alarm_actions
  ok_actions      = local.read_latency_conf.ok_actions

  tags = var.tags
}

module "write_latency" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = local.write_latency_conf.create_alarm
  alarm_name          = "${var.prefix}aurora_write_latency"
  alarm_description   = "High average Aurora write latency > ${local.write_latency_conf.threshold}ms. It may indicate slow queries."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = local.write_latency_conf.threshold

  metric_query = [{
    id          = "e1"
    expression  = "m1 * 1000"
    label       = "latency_into_milliseconds"
    return_data = "true"
    }, {
    id         = "m1"
    account_id = var.account_id

    metric = [{
      namespace   = "AWS/RDS"
      metric_name = "WriteLatency"
      period      = 60
      stat        = "Average"

      dimensions = {
        DBClusterIdentifier = var.db_cluster_identifier
      }
    }]
  }]

  actions_enabled = local.write_latency_conf.actions_enabled
  alarm_actions   = local.write_latency_conf.alarm_actions
  ok_actions      = local.write_latency_conf.ok_actions

  tags = var.tags
}
