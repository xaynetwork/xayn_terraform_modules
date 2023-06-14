locals {
  container_name = "bo"
  service_name   = "${local.container_name}-${var.id}"
  alb_rules      = [["/documents", "/documents/*", "/candidates", "/candidates/*", "/_ops/*"]]
}

module "service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.2.0"

  create = var.create

  name        = local.service_name
  cluster_arn = var.cluster_arn
  subnet_ids  = var.subnet_ids

  runtime_platform = {
    operating_system_family = "LINUX"
    cpu_architecture        = var.cpu_architecture
  }
  cpu           = var.container_cpu
  memory        = var.container_memory
  desired_count = var.desired_count

  container_definitions = {
    (local.container_name) = {
      image                                  = var.container_image
      enable_cloudwatch_logging              = true
      cloudwatch_log_group_retention_in_days = var.log_retention_in_days

      port_mappings = [
        {
          name          = local.container_name
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = concat(var.environment, [
        {
          name  = "XAYN_WEB_API__STORAGE__ELASTIC__URL"
          value = var.elasticsearch_url
        },
        {
          name  = "XAYN_WEB_API__STORAGE__ELASTIC__USER"
          value = var.elasticsearch_username
        },
        {
          name  = "XAYN_WEB_API__STORAGE__POSTGRES__BASE_URL"
          value = "${var.postgres_url}/${var.postgres_db}"
        },
        {
          name  = "XAYN_WEB_API__STORAGE__POSTGRES__USER"
          value = var.postgres_username
        },
        {
          name  = "XAYN_WEB_API__STORAGE__POSTGRES__APPLICATION_NAME"
          value = local.service_name
        },
        {
          name  = "XAYN_WEB_API__NET__BIND_TO"
          value = "0.0.0.0:${var.container_port}"
        },
        {
          name  = "XAYN_WEB_API__NET__CLIENT_REQUEST_TIMEOUT"
          value = var.request_timeout
        },
        {
          name  = "XAYN_WEB_API__NET__KEEP_ALIVE"
          value = var.keep_alive
        },
        {
          name  = "XAYN_WEB_API__NET__MAX_BODY_SIZE"
          value = var.max_http_body_size
        }
      ])

      secrets = [
        {
          name      = "XAYN_WEB_API__STORAGE__ELASTIC__PASSWORD"
          valueFrom = var.elasticsearch_password_ssm_parameter_arn
        },
        {
          name      = "XAYN_WEB_API__STORAGE__POSTGRES__PASSWORD"
          valueFrom = var.postgres_password_ssm_parameter_arn
        }
      ]
    }
  }

  deployment_circuit_breaker = {
    enable   = true
    rollback = true
  }

  load_balancer = {
    service = {
      target_group_arn = aws_lb_target_group.service.arn
      container_name   = local.container_name
      container_port   = var.container_port
    }
  }

  enable_autoscaling       = var.enable_autoscaling
  autoscaling_min_capacity = var.desired_count
  autoscaling_max_capacity = var.autoscaling_max_capacity
  autoscaling_policies = {
    cpu = {
      policy_type = "TargetTrackingScaling"

      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
      }
    }
  }

  autoscaling_scheduled_actions = var.autoscaling_scheduled_actions

  security_group_rules = {
    alb_ingress = {
      type                     = "ingress"
      description              = "Allow from ALB inbound traffic on container port"
      from_port                = var.container_port
      to_port                  = var.container_port
      protocol                 = "tcp"
      source_security_group_id = var.alb_security_group_id
    }
    egress_all = {
      type        = "egress"
      description = "Allow all egress traffic (Docker)"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  task_exec_ssm_param_arns = [var.elasticsearch_password_ssm_parameter_arn, var.postgres_password_ssm_parameter_arn]

  tags = var.tags
}

resource "aws_lb_target_group" "service" {
  name        = "${local.service_name}-tg"
  port        = var.alb_listener_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/health"
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "service" {
  count        = try(length(local.alb_rules), 0)
  listener_arn = var.alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service.arn
  }

  condition {
    path_pattern {
      values = local.alb_rules[count.index]
    }
  }

  tags = var.tags
}

# CloudWatch alarms
data "aws_caller_identity" "current" {}
module "alarms" {
  providers = {
    aws.monitoring-account = aws.monitoring-account
  }
  source = "../../../generic/alarms/ecs_service"

  count = var.create ? 1 : 0

  account_id = data.aws_caller_identity.current.account_id
  prefix     = "${data.aws_caller_identity.current.account_id}_"

  cluster_name   = var.cluster_name
  service_name   = module.service.name
  log_group_name = module.service.container_definitions.bo.cloudwatch_log_group_name

  cpu_usage = var.alarm_cpu_usage
  log_error = var.alarm_log_error

  tags = var.tags
}
