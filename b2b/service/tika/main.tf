data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name
}

module "task_role" {
  source = "../../../generic/service/role"

  description = "${var.name}'s task execution role for the tika API"
  path        = "/${var.name}/"
  prefix      = "${title(var.name)}TikaAPI"
  tags        = var.tags
}


module "security_group" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group?ref=v4.16.0"

  name        = "${var.name}-tika-api-sg"
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

  name               = "${var.name}-tika-api"
  security_group_ids = [module.security_group.security_group_id]

  cluster_id = var.cluster_id
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  alb = {
    listener_arn             = var.alb_listener_arn
    listener_port            = var.alb_listener_port
    health_path              = "/"
    routing_header_condition = null

    rules = [
      {
        routing_path_pattern = ["/rmeta", "/rmeta/*"]
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
  environment             = {}
  log_retention_in_days   = var.log_retention_in_days

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
