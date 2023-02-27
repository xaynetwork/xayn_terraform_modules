locals {
  read_latency_threshold  = lookup(var.read_latency, "threshold", 10)
  write_latency_threshold = lookup(var.write_latency, "threshold", 10)
}

module "read_latency" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = lookup(var.read_latency, "create_alarm", true)
  alarm_name          = "${var.prefix}aurora_read_latency"
  alarm_description   = "High Aurora read latency > ${var.read_latency_threshold}ms. It may indicate slow queries."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.read_latency_threshold

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

  actions_enabled = lookup(var.read_latency, "actions_enabled", true)
  alarm_actions   = lookup(var.read_latency, "alarm_actions", null)
  ok_actions      = lookup(var.read_latency, "ok_actions", null)

  tags = var.tags
}

module "write_latency" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  create_metric_alarm = lookup(var.write_latency, "create_alarm", true)
  alarm_name          = "${var.prefix}aurora_write_latency"
  alarm_description   = "High Aurora write latency > ${var.write_latency_threshold}ms. It may indicate slow queries."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.write_latency_threshold

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

  actions_enabled = lookup(var.write_latency, "actions_enabled", true)
  alarm_actions   = lookup(var.write_latency, "alarm_actions", null)
  ok_actions      = lookup(var.write_latency, "ok_actions", null)

  tags = var.tags
}
