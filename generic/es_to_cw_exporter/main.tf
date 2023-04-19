locals {
  es_exporter_remap_env_vars = [
    for k, v in var.es_exporter_environment : {
      name  = k
      value = v
    }
  ]

  es_exporter_remap_env_secrets = [
    for k, v in var.es_exporter_secrets : {
      name      = k
      valueFrom = v
    }
  ]

  pc_exporter_remap_env_vars = [
    for k, v in var.pc_exporter_environment : {
      name  = k
      value = v
    }
  ]
}

resource "aws_cloudwatch_log_group" "es_exporter_logs" {
  name              = "/ecs/container/${var.es_exporter_name}"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "pc_exporter_logs" {
  name              = "/ecs/container/${var.pc_exporter_name}"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

data "aws_region" "current" {}

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = templatefile("${path.module}/definition.json.tpl",
    {
      log_aws_region = data.aws_region.current.name,
      # elasticsearch exporter
      es_exporter_image          = var.es_exporter_container_image,
      es_exporter_name           = var.es_exporter_name,
      es_exporter_log_group      = aws_cloudwatch_log_group.es_exporter_logs.id,
      es_exporter_container_port = var.es_exporter_container_port,
      es_exporter_environment    = jsonencode(local.es_exporter_remap_env_vars),
      es_exporter_secrets        = jsonencode(local.es_exporter_remap_env_secrets)
      es_exporter_args           = jsonencode(var.es_exporter_args)
      # prometheus exporter
      pc_exporter_image     = var.pc_exporter_container_image,
      pc_exporter_name      = var.pc_exporter_name,
      pc_exporter_log_group = aws_cloudwatch_log_group.pc_exporter_logs.id,
      pc_exporter_environment = jsonencode(concat([{
        name  = "PROMETHEUS_SCRAPE_URL"
        value = "http://localhost:${var.es_exporter_container_port}/metrics"
      }], local.pc_exporter_remap_env_vars)),
    }
  )

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.task_cpu_architecture
  }

  tags = var.tags
}

resource "aws_ecs_service" "this" {
  name             = "${var.name}-svc"
  cluster          = var.cluster_id
  task_definition  = aws_ecs_task_definition.this.arn
  launch_type      = "FARGATE"
  platform_version = var.platform_version

  desired_count = 1
  deployment_circuit_breaker {
    enable = true
    # rollback if the new task fails to start
    rollback = true
  }

  network_configuration {
    security_groups = var.security_group_ids
    subnets         = var.subnet_ids
  }

  propagate_tags = "SERVICE"
  tags           = var.tags
}
