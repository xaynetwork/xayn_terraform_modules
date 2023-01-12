module "api_gateway_5xx_error_alarm" {
  count   = var.create_api_gateway_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "api_gateway_5xx_error"
  alarm_description   = "Number of API Gateway HTTP-5XX errors > ${var.api_gateway_5xx_error_threshold}. It may indicate an issue within the NLB integration or with the lambda authorizer."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.api_gateway_5xx_error_threshold
  period              = 60
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/ApiGateway"
  metric_name = "5XXError"
  statistic   = "Sum"

  dimensions = {
    ApiName = var.api_gateway_name
    Stage   = "default"
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

module "api_gateway_integration_latency_alarm" {
  count   = var.create_api_gateway_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "api_gateway_integration_latency"
  alarm_description   = "High integration latency from the system. Average integration latency > ${var.api_gateway_integration_latency_threshold}ms"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = var.api_gateway_integration_latency_threshold
  period              = 60
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/ApiGateway"
  metric_name = "IntegrationLatency"
  statistic   = "Average"

  dimensions = {
    ApiName = var.api_gateway_name
    Stage   = "default"
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

module "api_gateway_latency_alarm" {
  count   = var.create_api_gateway_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "api_gateway_latency"
  alarm_description   = "High latency in the API Gateway. Average latency > ${var.api_gateway_latency_threshold}ms"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = var.api_gateway_latency_threshold
  period              = 60
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/ApiGateway"
  metric_name = "Latency"
  statistic   = "Average"

  dimensions = {
    ApiName = var.api_gateway_name
    Stage   = "default"
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

module "users_service_cpu_alarm" {
  count   = var.create_ecs_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "users_service_cpu"
  alarm_description   = "High CPU usage for ${var.ecs_users_service_name} service. It may indicate that the auto scaling reach its maximum."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = var.users_service_cpu_threshold

  metric_query = [{
    id          = "e1"
    expression  = "m1 * 100 / m2"
    label       = "cpu_into_percentage"
    return_data = "true"
    },
    {
      id = "m1"

      metric = [{
        namespace   = "ECS/ContainerInsights"
        metric_name = "CpuUtilized"
        period      = 60
        stat        = "Sum"

        dimensions = {
          ClusterName = var.ecs_cluster_name
          ServiceName = var.ecs_users_service_name
        }
      }]
    },

    {
      id = "m2"

      metric = [{
        namespace   = "ECS/ContainerInsights"
        metric_name = "CpuReserved"
        period      = 60
        stat        = "Sum"

        dimensions = {
          ClusterName = var.ecs_cluster_name
          ServiceName = var.ecs_users_service_name
        }
      }]
  }]

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

module "documents_service_cpu_alarm" {
  count   = var.create_ecs_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "documents_service_cpu"
  alarm_description   = "High CPU usage for ${var.ecs_documents_service_name} service. It may indicate that the auto scaling reach its maximum."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = var.documents_service_cpu_threshold

  metric_query = [{
    id          = "e1"
    expression  = "m1 * 100 / m2"
    label       = "cpu_into_percentage"
    return_data = "true"
    }, {
    id = "m1"

    metric = [{
      namespace   = "ECS/ContainerInsights"
      metric_name = "CpuUtilized"
      period      = 60
      stat        = "Sum"

      dimensions = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_documents_service_name
      }
    }]
    }, {
    id = "m2"

    metric = [{
      namespace   = "ECS/ContainerInsights"
      metric_name = "CpuReserved"
      period      = 60
      stat        = "Sum"

      dimensions = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_documents_service_name
      }
    }]
  }]

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

module "users_log_errors" {
  count   = var.create_ecs_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-metric-filter"
  version = "4.2.1"

  log_group_name = var.ecs_users_log_group_name

  name    = "users-error-metric"
  pattern = var.ecs_users_log_pattern

  metric_transformation_namespace = "${var.ecs_cluster_name}/${var.ecs_users_service_name}"
  metric_transformation_name      = "ErrorCount"
}

module "documents_log_errors" {
  count   = var.create_ecs_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-metric-filter"
  version = "4.2.1"

  log_group_name = var.ecs_documents_log_group_name

  name    = "documents-error-metric"
  pattern = var.ecs_documents_log_pattern

  metric_transformation_namespace = "${var.ecs_cluster_name}/${var.ecs_documents_service_name}"
  metric_transformation_name      = "ErrorCount"
}

module "users_log_errors_alarm" {
  count   = var.create_ecs_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "users_log_errors"
  alarm_description   = "Number of errors in ${var.ecs_users_service_name} service > ${var.ecs_users_log_error_threshold}."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.ecs_users_log_error_threshold
  period              = 60
  treat_missing_data  = "notBreaching"

  namespace   = "${var.ecs_cluster_name}/${var.ecs_users_service_name}"
  metric_name = "ErrorCount"
  statistic   = "Sum"

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

module "documents_log_errors_alarm" {
  count   = var.create_ecs_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "documents_log_errors"
  alarm_description   = "Number of errors in ${var.ecs_documents_service_name} service > ${var.ecs_documents_log_error_threshold}."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.ecs_documents_log_error_threshold
  period              = 60
  treat_missing_data  = "notBreaching"

  namespace   = "${var.ecs_cluster_name}/${var.ecs_documents_service_name}"
  metric_name = "ErrorCount"
  statistic   = "Sum"

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}
