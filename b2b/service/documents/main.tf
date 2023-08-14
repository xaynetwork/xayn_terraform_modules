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
    rules = [
      {
        routing_header_condition = {
          name  = "X-Tenant-Id"
          value = var.tenant
        }
        routing_path_pattern = ["/documents", "/documents/*"]
      },
      {
        routing_header_condition = {
          name  = "X-Tenant-Id"
          value = var.tenant
        }
        routing_path_pattern = ["/candidates", "/candidates/*"]
      }
    ]
  }

  cpu_architecture        = var.cpu_architecture
  container_cpu           = var.container_cpu
  container_memory        = var.container_memory
  container_image         = var.container_image
  container_port          = var.container_port
  desired_count           = var.desired_count
  task_execution_role_arn = module.task_role.arn
  environment = {
    XAYN_WEB_API__NET__BIND_TO                          = "0.0.0.0:${var.container_port}"
    XAYN_WEB_API__STORAGE__ELASTIC__URL                 = var.elasticsearch_url
    XAYN_WEB_API__STORAGE__ELASTIC__INDEX_NAME          = var.elasticsearch_index
    XAYN_WEB_API__STORAGE__ELASTIC__USER                = var.elasticsearch_username
    XAYN_WEB_API__STORAGE__POSTGRES__BASE_URL           = "${var.postgres_url}/${var.tenant}"
    XAYN_WEB_API__STORAGE__POSTGRES__USER               = var.postgres_username
    XAYN_WEB_API__STORAGE__POSTGRES__APPLICATION_NAME   = var.tenant
    XAYN_WEB_API__NET__KEEP_ALIVE                       = var.keep_alive
    XAYN_WEB_API__NET__CLIENT_REQUEST_TIMEOUT           = var.request_timeout
    XAYN_WEB_API__LOGGING__LEVEL                        = var.logging_level
    XAYN_WEB_API__EMBEDDING__TOKEN_SIZE                 = var.token_size
    XAYN_WEB_API__INGESTION__MAX_SNIPPET_SIZE           = var.max_snippet_size
    XAYN_WEB_API__INGESTION__MAX_PROPERTIES_SIZE        = var.max_properties_size
    XAYN_WEB_API__INGESTION__MAX_PROPERTIES_STRING_SIZE = var.max_properties_string_size
    XAYN_WEB_API__TENANTS__ENABLE_DEV                   = var.enable_dev_options
  }
  secrets = {
    XAYN_WEB_API__STORAGE__ELASTIC__PASSWORD  = var.elasticsearch_password_ssm_parameter_arn
    XAYN_WEB_API__STORAGE__POSTGRES__PASSWORD = var.postgres_password_ssm_parameter_arn
  }

  log_retention_in_days = var.log_retention_in_days

  tags = var.tags
}

module "asg" {
  source = "../../../generic/service/asg"

  cluster_name       = var.cluster_name
  service_name       = module.service.name
  min_tasks          = var.desired_count
  max_tasks          = var.max_count
  target_value       = var.scale_target_value
  scale_in_cooldown  = var.scale_in_cooldown
  scale_out_cooldown = var.scale_out_cooldown
}

# CloudWatch alarms
data "aws_caller_identity" "current" {}
module "alarms" {
  providers = {
    aws.monitoring-account = aws.monitoring-account
  }
  source = "../../../generic/alarms/ecs_service"

  account_id = data.aws_caller_identity.current.account_id
  prefix     = "${data.aws_caller_identity.current.account_id}_"

  cluster_name   = var.cluster_name
  service_name   = module.service.name
  log_group_name = module.service.log_group_name

  cpu_usage = var.alarm_cpu_usage
  log_error = var.alarm_log_error

  tags = var.tags
}
