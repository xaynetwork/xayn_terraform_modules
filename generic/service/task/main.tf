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

  log_group_name = "/ecs/task/${var.name}"
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
  task_role_arn            = var.task_role_arn

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

  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage == null ? [] : [1]
    content {
      size_in_gib = var.ephemeral_storage
    }
  }

  tags = var.tags
}
