module "task_role" {
  source = "../../generic/service/role"

  description = "Execution role for Pull Embedding Service ECS service"
  path        = "/nc-semantic-search/"
  prefix      = "NcSemanticSearch"
  tags        = var.tags
}

module "security_group" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group?ref=v4.16.0"

  name        = "nc-semantic-search-sg"
  description = "Allow only incoming traffic from alb"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      description              = "Allow from ALB inbound traffic on container port"
      from_port                = var.container_port
      to_port                  = var.container_port
      protocol                 = "tcp"
      source_security_group_id = var.alb_security_group_id
    }
  ]
  // we could reduce the access to https://ip-ranges.amazonaws.com/ip-ranges.json
  // ECR is currectly available at: 3.122.9.124 which is not listed as a prefix in ^^
  egress_with_cidr_blocks = [
    {
      description = "Allow all egress traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
  }]
  tags = var.tags
}

module "service" {
  source = "../../generic/service/service"

  name               = "nc-semantic-search"
  security_group_ids = [module.security_group.security_group_id]

  health_check_grace_period_seconds = 30

  alb = {
    listener_arn         = var.alb_listener_arn
    listener_port        = var.alb_listener_port
    health_path          = "/health"
    routing_path_pattern = ["/embeddings"]
  }

  cluster_id = var.cluster_id
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  container_cpu              = var.container_cpu
  container_memory           = var.container_memory
  container_image            = var.container_image
  container_port             = var.container_port
  desired_count              = var.desired_count
  task_execution_role_arn    = module.task_role.arn
  capacity_provider_strategy = var.capacity_provider_strategy

  environment = {
    XAYN_SEMANTIC_SEARCH__NET__BIND_TO                = "0.0.0.0:${var.container_port}"
    XAYN_SEMANTIC_SEARCH__NET__KEEP_ALIVE             = var.keep_alive
    XAYN_SEMANTIC_SEARCH__NET__CLIENT_REQUEST_TIMEOUT = var.request_timeout
    XAYN_SEMANTIC_SEARCH__LOGGING__LEVEL              = var.logging_level
  }

  tags = var.tags
}

module "asg" {
  source = "../../generic/service/asg"

  cluster_name = var.cluster_name
  service_name = module.service.name
  min_tasks    = var.desired_count
  max_tasks    = var.max_count
}


# cloudwatch alarms
module "service_cpu_alarm" {
  count   = var.create_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "semantic_search_service_cpu"
  alarm_description   = "High CPU usage for ${module.service.name} service. It may indicate that the auto scaling reach its maximum."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = var.service_cpu_threshold

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
        ClusterName = var.cluster_name
        ServiceName = module.service.name
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
        ClusterName = var.cluster_name
        ServiceName = module.service.name
      }
    }]
  }]

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
  ok_actions    = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  tags = var.tags
}

module "log_error_filter" {
  count   = var.create_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-metric-filter"
  version = "4.2.1"

  log_group_name = module.service.log_group_name

  name    = "semantic_search_error_metric"
  pattern = var.log_pattern

  metric_transformation_namespace = "${var.cluster_name}/${module.service.name}"
  metric_transformation_name      = "ErrorCount"
}

module "log_error_alarm" {
  count   = var.create_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "semantic_search_log_errors"
  alarm_description   = "Number of errors in ${module.service.name} service > ${var.log_error_threshold}."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.log_error_threshold
  period              = 60
  treat_missing_data  = "notBreaching"

  namespace   = "${var.cluster_name}/${module.service.name}"
  metric_name = "ErrorCount"
  statistic   = "Sum"

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
  ok_actions    = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  tags = var.tags
}
