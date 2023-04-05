module "task_role" {
  source = "../../generic/service/role"

  description = "Execution role for Semantic Search Service ECS service"
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
  // ECR is currently available at: 3.122.9.124 which is not listed as a prefix in ^^
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
    listener_arn  = var.alb_listener_arn
    listener_port = var.alb_listener_port
    health_path   = "/health"
    rules = [{
      routing_header_condition = null
      routing_path_pattern     = ["/embeddings"]
    }]
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
    XAYN_SEMANTIC_SEARCH__EMBEDDING__TOKEN_SIZE       = var.token_size
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

# CloudWatch alarms
data "aws_caller_identity" "current" {}
module "alarms" {
  providers = {
    aws.monitoring-account = aws.monitoring-account
  }
  source = "../../generic/alarms/ecs_service"

  account_id = data.aws_caller_identity.current.account_id
  prefix     = "${data.aws_caller_identity.current.account_id}_"

  cluster_name   = var.cluster_name
  service_name   = module.service.name
  log_group_name = module.service.log_group_name

  cpu_usage = var.alarm_cpu_usage
  log_error = var.alarm_log_error

  tags = var.tags
}
