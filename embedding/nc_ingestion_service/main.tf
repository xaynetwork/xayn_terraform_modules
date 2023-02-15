module "task_role" {
  source = "../../generic/service/role"

  description = "Execution role for Nc Ingestion ECS service"
  path        = "/nc-ingestion/"
  prefix      = "NcIngestion"
  tags        = var.tags
}

module "security_group" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group?ref=v4.16.0"

  name        = "nc-ingestion-service-sg"
  description = "Allow all egress traffic"
  vpc_id      = var.vpc_id

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

resource "aws_ssm_parameter" "auth_json" {
  description = "The secure auth json"
  name        = "/nc_ingestion/auth_json"
  type        = "SecureString"
  value       = var.auth_json
  tags        = var.tags
}


module "secret_policy" {
  source = "../../generic/service/secret_policy"

  role_name          = module.task_role.name
  ssm_parameter_arns = [aws_ssm_parameter.auth_json.arn]
  description        = "Allow documents api service access to parameter store"
  path               = "/nc_ingestion/"
  prefix             = "NcIngestion"
  tags               = var.tags
}

module "service" {
  source = "../../generic/service/service"

  name               = "nc-ingestion"
  security_group_ids = [module.security_group.security_group_id]

  # this only applies for services with a load balancer
  health_check_grace_period_seconds = null

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
    "INGESTION_INPUT_QUEUE"  = "v2-xayn-consume-articles"
    "INGESTION_OUTPUT_QUEUE" = "v2-xayn-publish-articles"
    "INGESTION_MODEL_PATH"   = "./model"
  }
  secrets = {
    AUTH_JSON = aws_ssm_parameter.auth_json.arn
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
