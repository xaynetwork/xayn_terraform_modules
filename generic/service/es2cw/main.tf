locals {
  remap_env_vars = [
    for k, v in var.environment : {
      name  = k
      value = v
    }
  ]
}

module "task_role" {
  source = "../role"

  description = "Task execution role for Monitoring ES"
  path        = "/monitoring/"
  prefix      = "Monitoring"
  tags        = var.tags
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = module.task_role.arn

  container_definitions = templatefile("${path.module}/definition.json.tpl",
    {
      image          = var.container_image,
      cpu            = var.container_cpu,
      memory         = var.container_memory
      name           = var.name,
      container_port = var.container_port,
      container_cmd  = var.container_cmd
      environment    = jsonencode(local.remap_env_vars),
    }
  )

  tags = var.tags
}

resource "aws_ecs_service" "this" {
  name             = "${var.name}-svc"
  cluster          = var.cluster_id
  desired_count    = var.desired_count
  task_definition  = aws_ecs_task_definition.this.arn

  network_configuration {
    subnets         = var.subnet_ids
  }

  propagate_tags = "SERVICE"
  tags           = var.tags
}
