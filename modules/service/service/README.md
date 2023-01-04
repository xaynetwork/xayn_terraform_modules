# AWS ECS service Terraform module

Terraform module which creates an ECS service on AWS.

## Usage

```hcl
module "service" {
  source = "../../modules/service/service"

  name       = "users_api"
  cluster_id = "cluster-1"
  vpc_id     = "vpc-1"
  subnet_ids = ["subnet-1"]

  container_image = "xaynetci/example:v0.0.1"
  container_port  = 8000

  alb_listener_arn         = "arn::"
  alb_listener_port        = 80
  alb_health_path          = "/health"
  alb_routing_path_pattern = ["users/*"]

  # optional
  task_execution_role_arn = "arn::"
  container_cpu           = 512
  container_memory        = 256
  cpu_architecture        = "ARM64"
  environment = {
    PORT = 8000
  }
  secrets = {
    PASSWORD = "arn::"
  }

  log_retention_in_days              = 7
  platform_version                   = "1.4.0"
  security_group_ids                 = ["sg-1"]
  desired_count                      = 2
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 200
  deployment_circuit_breaker = {
    enable   = true
    rollback = true
  }
  health_check_grace_period_seconds  = 30
  alb_routing_header                 = "header"

  tags      = {
    Product = "b2b"
    User    = "provider"
  }
}
```
