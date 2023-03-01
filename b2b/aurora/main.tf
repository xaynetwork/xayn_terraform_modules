data "aws_subnet" "private" {
  for_each = toset(var.subnets)
  id       = each.key
}

locals {
  availability_zone_subnets = [
    for s in data.aws_subnet.private : s.availability_zone
  ]
}

data "aws_iam_policy_document" "monitoring_rds_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

data "aws_partition" "current" {}

module "security_group" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group?ref=v4.16.0"

  name        = "${var.name}-sg"
  description = "Security group for the Aurora Database"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = var.subnets_cidr_blocks

  ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      description = "Postgres port"
    }
  ]

  tags = var.tags
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  description         = "IAM Role for RDS Enhanced monitoring"
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.monitoring_rds_assume_role.json
  managed_policy_arns = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
  tags                = var.tags
}

resource "aws_rds_cluster" "this" {
  cluster_identifier              = var.name
  engine                          = "aurora-postgresql"
  engine_mode                     = "provisioned"
  engine_version                  = var.engine_version
  availability_zones              = local.availability_zone_subnets
  db_subnet_group_name            = aws_db_subnet_group.db_subnet_group.name
  master_username                 = var.db_admin_username
  master_password                 = var.db_admin_password
  backup_retention_period         = var.backup_retention_period
  skip_final_snapshot             = var.skip_final_snapshot
  enabled_cloudwatch_logs_exports = ["postgresql"]
  copy_tags_to_snapshot           = true
  storage_encrypted               = true
  vpc_security_group_ids          = [module.security_group.security_group_id]

  serverlessv2_scaling_configuration {
    max_capacity = var.max_scaling
    min_capacity = var.min_scaling
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      availability_zones,
    ]
  }
}

resource "aws_rds_cluster_instance" "this" {
  count                        = var.instance_count
  identifier                   = "${var.name}-${count.index}"
  cluster_identifier           = aws_rds_cluster.this.id
  engine                       = aws_rds_cluster.this.engine
  engine_version               = aws_rds_cluster.this.engine_version
  instance_class               = var.instance_class
  db_subnet_group_name         = aws_db_subnet_group.db_subnet_group.name
  publicly_accessible          = false
  performance_insights_enabled = true
  monitoring_interval          = var.monitoring_interval
  monitoring_role_arn          = aws_iam_role.rds_enhanced_monitoring.arn
  tags                         = var.tags
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.name}-db-subnet-group"
  subnet_ids = var.subnets
  tags       = var.tags
}

resource "aws_ssm_parameter" "postgres_url" {
  name        = "/postgres/${var.name}/url"
  description = "Connection string of the aurora cluster"
  type        = "String"
  value       = "postgresql://user:password@${aws_rds_cluster.this.endpoint}"
  tags        = var.tags
}

resource "aws_ssm_parameter" "postgres_username" {
  name        = "/postgres/${var.name}/username"
  description = "Aurora username"
  type        = "SecureString"
  value       = var.db_admin_username
  tags        = var.tags
}

resource "aws_ssm_parameter" "postgres_password" {
  name        = "/postgres/${var.name}/password"
  description = "Aurora password"
  type        = "SecureString"
  value       = var.db_admin_password
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
