module "execution_role" {
  source = "../../../generic/service/role"

  description = "ElasticSearch to CloudWatch metric exporter execution role"
  prefix      = "EsToCwMetricExporter"
  tags        = var.tags
}

module "secret_policy" {
  source = "../../../generic/service/secret_policy"

  role_name          = module.execution_role.name
  ssm_parameter_arns = [var.elasticsearch_password_ssm_parameter_arn]
  description        = "Allow ElasticSearch to CloudWatch metric exporter access to the parameter store"
  prefix             = "EsToCwMetricExporter"
  tags               = var.tags
}

module "security_group" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group?ref=v4.16.0"

  name        = "es-to-cw-metric-exporter-sg"
  description = "Forbid inbound traffic, Allow all egress traffic (Docker, ElasticSearch and CloudWatch)"
  vpc_id      = var.vpc_id

  egress_with_cidr_blocks = [
    {
      description = "Allow all egress traffic (Docker, ElasticSearch and CloudWatch)"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
  }]
  tags = var.tags
}

data "aws_region" "current" {}

module "service" {
  source = "../../../generic/es_to_cw_exporter"

  name               = "es-to-cw-metric-exporter"
  security_group_ids = [module.security_group.security_group_id]

  cluster_id = var.cluster_id
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  task_cpu_architecture = var.task_cpu_architecture
  task_cpu              = var.task_cpu
  task_memory           = var.task_memory
  execution_role_arn    = module.execution_role.arn
  task_role_arn         = aws_iam_role.ecs_task_role.arn

  # elasticsearch exporter settings
  es_exporter_container_image = var.es_exporter_container_image
  es_exporter_args = [
    "--es.uri=${var.elasticsearch_url}",
    # "--es.all",
    # "--es.indices",
    "--es.clusterinfo.interval=${var.es_exporter_scrape_interval}"
  ]
  es_exporter_environment = {
    ES_USERNAME = var.elasticsearch_username
  }
  es_exporter_secrets = {
    ES_PASSWORD = var.elasticsearch_password_ssm_parameter_arn
  }

  # prometheus exporter settings
  pc_exporter_container_image = var.pc_exporter_container_image
  pc_exporter_environment = {
    CLOUDWATCH_NAMESPACE       = "ElasticSearch/${var.es_cluster_name}"
    CLOUDWATCH_REGION          = data.aws_region.current.name
    PROMETHEUS_SCRAPE_INTERVAL = var.pc_exporter_scrape_interval
    INCLUDE_METRICS            = var.pc_exporter_include_metrics
  }

  tags = var.tags
}
