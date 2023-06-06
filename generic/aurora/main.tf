data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = var.engine_version
}

module "aurora_postgresql_v2" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "8.3.0"

  name                        = var.name
  engine                      = data.aws_rds_engine_version.postgresql.engine
  engine_mode                 = "provisioned"
  engine_version              = data.aws_rds_engine_version.postgresql.version
  storage_encrypted           = true
  copy_tags_to_snapshot       = true
  deletion_protection         = var.deletion_protection
  master_username             = var.master_username
  manage_master_user_password = false
  master_password             = var.master_password

  vpc_id               = var.vpc_id
  db_subnet_group_name = var.vpc_database_subnet_group_name
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = var.vpc_private_subnets_cidr_blocks
    }
  }

  apply_immediately = var.apply_immediately

  monitoring_interval          = var.monitoring_interval
  performance_insights_enabled = var.performance_insights_enabled

  create_cloudwatch_log_group     = true
  enabled_cloudwatch_logs_exports = ["postgresql"]

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot

  serverlessv2_scaling_configuration = {
    max_capacity = var.max_scaling
    min_capacity = var.min_scaling
  }

  instance_class = "db.serverless"
  instances      = var.instances

  tags = var.tags
}

resource "aws_ssm_parameter" "postgres_url" {
  name        = "/postgres/${var.name}/url"
  description = "Connection string of the aurora cluster"
  type        = "String"
  value       = "postgresql://user:password@${module.aurora_postgresql_v2.cluster_endpoint}"
  tags        = var.tags
}

resource "aws_ssm_parameter" "postgres_username" {
  name        = "/postgres/${var.name}/username"
  description = "Aurora username"
  type        = "SecureString"
  value       = module.aurora_postgresql_v2.cluster_master_username
  tags        = var.tags
}

# cloudwatch alarms
data "aws_caller_identity" "current" {}
module "alarms" {
  providers = {
    aws = aws.monitoring-account
  }
  source = "../../generic/alarms/aurora"

  account_id = data.aws_caller_identity.current.account_id
  prefix     = "${data.aws_caller_identity.current.account_id}_"

  db_cluster_identifier = var.name

  read_latency  = var.alarm_read_latency
  write_latency = var.alarm_write_latency

  tags = var.tags
}
