module "task_role" {
  source = "../../generic/service/role"

  description = "Execution role for Pull Embedding Service ECS service"
  path        = "/pull-embedding-service/"
  prefix      = "PullEmbeddingService"
  tags        = var.tags
}

module "security_group" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group?ref=v4.16.0"

  name        = "pull-embedding-service-sg"
  description = "Allow all egress traffic"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
  ]
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

  name               = "pull-embedding-service"
  security_group_ids = [module.security_group.security_group_id]

  # this only applies for services with a load balancer
  health_check_grace_period_seconds = null

  cluster_id = var.cluster_id
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  container_cpu           = var.container_cpu
  container_memory        = var.container_memory
  container_image         = var.container_image
  container_port          = var.container_port
  desired_count           = var.desired_count
  task_execution_role_arn = module.task_role.arn
  environment = {
    AUTH_JSON = var.auth_json
  }
  secrets = {
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
