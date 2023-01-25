data "aws_region" "current" {}

locals {
  remap_env_vars = [
    for k, v in var.environment : {
      name  = k
      value = v
    }
  ]

  remap_env_secrets = [
    for k, v in var.secrets : {
      name      = k
      valueFrom = v
    }
  ]

  log_group_name = "/ecs/service/${var.name}"
}

resource "aws_cloudwatch_log_group" "container_logs" {
  name              = local.log_group_name
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.task_execution_role_arn

  container_definitions = templatefile("${path.module}/definition.json.tpl",
    {
      image          = var.container_image,
      cpu            = var.container_cpu,
      memory         = var.container_memory
      name           = var.name,
      log_group      = aws_cloudwatch_log_group.container_logs.id,
      aws_region     = data.aws_region.current.name,
      container_port = var.container_port,
      environment    = jsonencode(local.remap_env_vars),
      secrets        = jsonencode(local.remap_env_secrets)
    }
  )

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.cpu_architecture
  }

  tags = var.tags
}

resource "aws_ecs_service" "this" {
  name             = "${var.name}-svc"
  cluster          = var.cluster_id
  task_definition  = aws_ecs_task_definition.this.arn
  launch_type      = "FARGATE"
  platform_version = var.platform_version

  desired_count = var.desired_count
  # during the deployment allow to double the number of running tasks
  deployment_maximum_percent = var.deployment_maximum_percent
  # during the deployment the number of healthy tasks should not fall below
  # desired_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_circuit_breaker {
    enable = var.deployment_circuit_breaker.enable
    # rollback if the new task fails to start
    rollback = var.deployment_circuit_breaker.rollback
  }

  network_configuration {
    security_groups = var.security_group_ids
    subnets         = var.subnet_ids
  }

  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  dynamic "load_balancer" {
    for_each = length(aws_lb_target_group.service) > 0 ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.service[0].arn
      container_name   = var.name
      container_port   = var.container_port
    }
  }

  # FARGATE
  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy == null ? [] : [1]
    content {
      base              = var.capacity_provider_strategy.fargate_base
      weight            = var.capacity_provider_strategy.fargate_weight
      capacity_provider = "FARGATE"
    }
  }

  # FARGATE_SPOT
  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy == null ? [] : [1]
    content {
      base              = var.capacity_provider_strategy.fargate_spot_base
      weight            = var.capacity_provider_strategy.fargate_spot_weight
      capacity_provider = "FARGATE_SPOT"
    }
  }

  # ignore desired_count as it will be dynamic through the autoscaling group
  lifecycle {
    ignore_changes = [desired_count]
  }

  propagate_tags = "SERVICE"
  tags           = var.tags
}

resource "aws_lb_target_group" "service" {
  count       = var.alb == null ? 0 : 1
  name        = "${var.name}-tg"
  port        = var.alb.listener_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = var.alb.health_path
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "service" {
  count        = var.alb == null ? 0 : 1
  listener_arn = var.alb.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service[0].arn
  }

  condition {
    path_pattern {
      values = var.alb.routing_path_pattern
    }
  }

  dynamic "condition" {
    for_each = var.alb_routing_header_condition != null ? [1] : []
    content {
      http_header {
        http_header_name = var.alb_routing_header_condition.name
        values           = [var.alb_routing_header_condition.value]
      }
    }
  }

  tags = var.tags
}
