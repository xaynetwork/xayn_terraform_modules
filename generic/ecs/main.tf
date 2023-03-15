resource "aws_ecs_cluster" "this" {
  name = var.name

  setting {
    name  = "containerInsights"
    value = var.container_insights ? "enabled" : "disabled"
  }
  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  count        = var.capacity_provider_strategy == null ? 0 : 1
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = var.capacity_provider_strategy.fargate_base
    weight            = var.capacity_provider_strategy.fargate_weight
    capacity_provider = "FARGATE"
  }

  default_capacity_provider_strategy {
    base              = var.capacity_provider_strategy.fargate_spot_base
    weight            = var.capacity_provider_strategy.fargate_spot_weight
    capacity_provider = "FARGATE_SPOT"
  }
}

