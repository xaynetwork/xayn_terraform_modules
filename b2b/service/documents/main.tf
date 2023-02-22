module "task_role" {
  source = "../../../generic/service/role"

  description = "${var.tenant}'s task execution role for documents API ECS service"
  path        = "/${var.tenant}/"
  prefix      = "${title(var.tenant)}DocumentsAPI"
  tags        = var.tags
}

module "secret_policy" {
  source = "../../../generic/service/secret_policy"

  role_name          = module.task_role.name
  ssm_parameter_arns = [var.elasticsearch_password_ssm_parameter_arn, var.postgres_password_ssm_parameter_arn]
  description        = "Allow documents api service access to parameter store"
  path               = "/${var.tenant}/"
  prefix             = "${title(var.tenant)}DocumentsAPI"
  tags               = var.tags
}

module "security_group" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group?ref=v4.16.0"

  name        = "${var.tenant}-documents-api-sg"
  description = "Allow from ALB inbound traffic, Allow all egress traffic (Docker)"
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
  egress_with_cidr_blocks = [
    {
      description = "Allow all egress traffic (Docker)"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
  }]
  tags = var.tags
}

module "service" {
  source = "../../../generic/service/service"

  name               = "${var.tenant}-documents-api"
  security_group_ids = [module.security_group.security_group_id]

  cluster_id = var.cluster_id
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  alb = {
    listener_arn  = var.alb_listener_arn
    listener_port = var.alb_listener_port
    health_path   = "/health"
    rules = [{
      routing_header_condition = {
        name  = "X-Tenant-Id"
        value = var.tenant
      }
      routing_path_pattern = ["/documents", "/documents/*"]
    }]
  }

  container_cpu           = var.container_cpu
  container_memory        = var.container_memory
  container_image         = var.container_image
  container_port          = var.container_port
  desired_count           = var.desired_count
  task_execution_role_arn = module.task_role.arn
  environment = {
    XAYN_WEB_API__NET__BIND_TO                 = "0.0.0.0:${var.container_port}"
    XAYN_WEB_API__STORAGE__ELASTIC__URL        = var.elasticsearch_url
    XAYN_WEB_API__STORAGE__ELASTIC__INDEX_NAME = var.elasticsearch_index
    XAYN_WEB_API__STORAGE__ELASTIC__USER       = var.elasticsearch_username
    XAYN_WEB_API__STORAGE__POSTGRES__BASE_URL  = "${var.postgres_url}/${var.tenant}"
    XAYN_WEB_API__STORAGE__POSTGRES__USER      = var.postgres_username
    XAYN_WEB_API__NET__KEEP_ALIVE              = var.keep_alive
    XAYN_WEB_API__NET__CLIENT_REQUEST_TIMEOUT  = var.request_timeout
    XAYN_WEB_API__LOGGING__LEVEL               = var.logging_level
  }
  secrets = {
    XAYN_WEB_API__STORAGE__ELASTIC__PASSWORD  = var.elasticsearch_password_ssm_parameter_arn
    XAYN_WEB_API__STORAGE__POSTGRES__PASSWORD = var.postgres_password_ssm_parameter_arn
  }

  tags = var.tags
}

module "asg" {
  source = "../../../generic/service/asg"

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

  alarm_name          = "documents_service_cpu_${var.tenant}"
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

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

module "log_error_filter" {
  count   = var.create_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-metric-filter"
  version = "4.2.1"

  log_group_name = module.service.log_group_name

  name    = "documents_error_metric_${var.tenant}"
  pattern = var.log_pattern

  metric_transformation_namespace = "${var.cluster_name}/${module.service.name}"
  metric_transformation_name      = "ErrorCount"
}

module "log_error_alarm" {
  count   = var.create_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "documents_log_errors_${var.tenant}"
  alarm_description   = "Number of errors in ${module.service.name} service > ${var.log_error_threshold} for tenant ${var.tenant}."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.log_error_threshold
  period              = 60
  treat_missing_data  = "notBreaching"

  namespace   = "${var.cluster_name}/${module.service.name}"
  metric_name = "ErrorCount"
  statistic   = "Sum"

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}
