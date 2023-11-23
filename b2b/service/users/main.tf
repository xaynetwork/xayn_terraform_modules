data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  create_task_role    = length(var.sagemaker_endpoint) > 0 ? true : false
  use_openai_endpoint = length(var.openai_endpoint) > 0 ? true : false
  account_id          = data.aws_caller_identity.current.account_id
  partition           = data.aws_partition.current.partition
  region              = data.aws_region.current.name
}

resource "null_resource" "validate" {
  triggers = {
    input = timestamp()
  }

  lifecycle {
    postcondition {
      condition     = (local.create_task_role && try(var.sagemaker_endpoint.name, null) != null && try(var.sagemaker_endpoint.model_embedding_size, null) != null) || !local.create_task_role
      error_message = "In combination with sagemaker, the model embedding size need to be specified."
    }
    postcondition {
      condition     = !(local.create_task_role && local.use_openai_endpoint)
      error_message = "Can not define sagemaker and openai_endpoints together, just use one of both."
    }
  }
}

data "aws_iam_policy_document" "ecs_service_role" {
  count = local.create_task_role ? 1 : 0
  statement {
    sid     = "${title(var.tenant)}UsersEcsTaskRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sagemaker" {
  count = local.create_task_role ? 1 : 0

  name               = "${title(var.tenant)}UsersEcsTaskRole"
  description        = "Allows the ECS Task to access sagemaker"
  path               = "/${var.tenant}/"
  assume_role_policy = data.aws_iam_policy_document.ecs_service_role[0].json
  tags               = var.tags
}

data "aws_iam_policy_document" "sagemaker_invocation" {
  count = local.create_task_role ? 1 : 0
  statement {
    effect    = "Allow"
    actions   = ["sagemaker:InvokeEndpoint"]
    resources = ["arn:${local.partition}:sagemaker:${local.region}:${local.account_id}:endpoint/${var.sagemaker_endpoint.name}"]
  }
}

resource "aws_iam_policy" "sagemaker" {
  count  = local.create_task_role ? 1 : 0
  name   = "${title(var.tenant)}UsersEcsTaskPolicy"
  policy = data.aws_iam_policy_document.sagemaker_invocation[0].json
}

resource "aws_iam_role_policy_attachment" "sagemaker" {
  count      = local.create_task_role ? 1 : 0
  policy_arn = aws_iam_policy.sagemaker[0].arn
  role       = aws_iam_role.sagemaker[0].name
}

module "task_role" {
  source = "../../../generic/service/role"

  description = "${var.tenant}'s task execution role for users API ECS service"
  path        = "/${var.tenant}/"
  prefix      = "${title(var.tenant)}UserAPI"
  tags        = var.tags
}

module "secret_policy" {
  source = "../../../generic/service/secret_policy"

  role_name          = module.task_role.name
  ssm_parameter_arns = [var.elasticsearch_password_ssm_parameter_arn, var.postgres_password_ssm_parameter_arn]
  description        = "Allow users api service access to parameter store"
  path               = "/${var.tenant}/"
  prefix             = "${title(var.tenant)}UserAPI"
  tags               = var.tags
}

module "security_group" {
  depends_on = [null_resource.validate]
  source     = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group?ref=v4.16.0"

  name        = "${var.tenant}-users-api-sg"
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

  name               = "${var.tenant}-users-api"
  security_group_ids = [module.security_group.security_group_id]

  cluster_id = var.cluster_id
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  alb = {
    listener_arn  = var.alb_listener_arn
    listener_port = var.alb_listener_port
    health_path   = "/health"
    rules = [
      {
        routing_path_pattern = ["/users", "/users/*"]
        routing_header_condition = {
          name  = "X-Tenant-Id"
          value = var.tenant
        }
      },
      {
        routing_path_pattern = ["/semantic_search", "/semantic_search/*", "/recommendations", "/recommendations/*"]
        routing_header_condition = {
          name  = "X-Tenant-Id"
          value = var.tenant
        }
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
  task_role_arn           = local.create_task_role ? aws_iam_role.sagemaker[0].arn : null
  environment = merge({
    XAYN_WEB_API__NET__BIND_TO                              = "0.0.0.0:${var.container_port}"
    XAYN_WEB_API__STORAGE__ELASTIC__URL                     = var.elasticsearch_url
    XAYN_WEB_API__STORAGE__ELASTIC__INDEX_NAME              = var.elasticsearch_index
    XAYN_WEB_API__STORAGE__ELASTIC__USER                    = var.elasticsearch_username
    XAYN_WEB_API__STORAGE__POSTGRES__BASE_URL               = "${var.postgres_url}/${var.tenant}"
    XAYN_WEB_API__STORAGE__POSTGRES__USER                   = var.postgres_username
    XAYN_WEB_API__STORAGE__POSTGRES__APPLICATION_NAME       = var.tenant
    XAYN_WEB_API__PERSONALIZATION__MAX_COIS_FOR_KNN         = var.max_cois
    XAYN_WEB_API__PERSONALIZATION__DEFAULT_NUMBER_DOCUMENTS = 10
    XAYN_WEB_API__SEMANTIC_SEARCH__MAX_NUMBER_DOCUMENTS     = var.max_documents
    XAYN_WEB_API__SEMANTIC_SEARCH__MAX_NUMBER_CANDIDATES    = var.max_candidates
    XAYN_WEB_API__SEMANTIC_SEARCH__MAX_QUERY_SIZE           = var.max_query_size
    XAYN_WEB_API__NET__KEEP_ALIVE                           = var.keep_alive
    XAYN_WEB_API__NET__CLIENT_REQUEST_TIMEOUT               = var.request_timeout
    XAYN_WEB_API__LOGGING__LEVEL                            = var.logging_level
    XAYN_WEB_API__TENANTS__ENABLE_DEV                       = var.enable_dev_options
    }, local.create_task_role ? {
    XAYN_WEB_API__EMBEDDING__TYPE           = "sagemaker",
    XAYN_WEB_API__EMBEDDING__ENDPOINT       = var.sagemaker_endpoint.name,
    XAYN_WEB_API__EMBEDDING__EMBEDDING_SIZE = var.sagemaker_endpoint.model_embedding_size
    } : local.use_openai_endpoint ? {
    XAYN_WEB_API__EMBEDDING__TYPE           = "open_ai",
    XAYN_WEB_API__EMBEDDING__URL            = "${var.openai_endpoint.url}&user=${var.tenant}",
    XAYN_WEB_API__EMBEDDING__API_KEY        = var.openai_endpoint.api_key,
    XAYN_WEB_API__EMBEDDING__EMBEDDING_SIZE = var.sagemaker_endpoint.model_embedding_size
    } : {
    XAYN_WEB_API__EMBEDDING__TYPE       = "pipeline",
    XAYN_WEB_API__EMBEDDING__TOKEN_SIZE = var.token_size
    },
    local.create_task_role && try(var.sagemaker_endpoint.target_model, null) != null ? { XAYN_WEB_API__EMBEDDING__TARGET_MODEL = var.sagemaker_endpoint.target_model } : {},
    local.create_task_role && try(var.sagemaker_endpoint.max_retries, null) != null ? { XAYN_WEB_API__EMBEDDING__RETRY_MAX_ATTEMPTS = var.sagemaker_endpoint.max_retries } : {},
  )

  secrets = {
    XAYN_WEB_API__STORAGE__ELASTIC__PASSWORD  = var.elasticsearch_password_ssm_parameter_arn
    XAYN_WEB_API__STORAGE__POSTGRES__PASSWORD = var.postgres_password_ssm_parameter_arn
  }

  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  log_retention_in_days = var.log_retention_in_days

  tags = var.tags
}

module "asg" {
  source = "../../../generic/service/asg"

  cluster_name      = var.cluster_name
  service_name      = module.service.name
  min_tasks         = var.desired_count
  max_tasks         = var.max_count
  scheduled_scaling = var.scheduled_scaling
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
