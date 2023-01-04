module "security_group" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group?ref=v4.16.0"

  name        = "${var.name}-sg"
  description = "Security group for the Database"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = var.subnets_cidr

  ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      description = "Postgres port"
    }
  ]

  tags = var.tags
}

resource "aws_db_subnet_group" "private_subnets" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnets
  tags       = var.tags
}

resource "aws_db_instance" "postgres" {
  identifier                      = var.name
  username                        = var.postgres_admin_username
  password                        = var.postgres_admin_password
  db_subnet_group_name            = aws_db_subnet_group.private_subnets.name
  instance_class                  = var.instance
  allocated_storage               = var.allocated_storage
  max_allocated_storage           = var.max_allocated_storage
  engine                          = "postgres"
  engine_version                  = var.postgres_version
  skip_final_snapshot             = var.skip_final_snapshot
  publicly_accessible             = false
  vpc_security_group_ids          = [module.security_group.security_group_id]
  multi_az                        = var.multi_az
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  backup_retention_period         = var.backup_retention_period
  storage_encrypted               = true
  tags                            = var.tags
}

resource "aws_ssm_parameter" "postgres_url" {
  name        = "/postgres/${var.name}/url"
  description = "Connection string of the postgres cluster"
  type        = "String"
  value       = "postgresql://user:password@${aws_db_instance.postgres.address}"
  tags        = var.tags
}

resource "aws_ssm_parameter" "postgres_username" {
  name        = "/postgres/${var.name}/username"
  description = "Postgres username"
  type        = "SecureString"
  value       = var.postgres_admin_username
  tags        = var.tags
}

resource "aws_ssm_parameter" "postgres_password" {
  name        = "/postgres/${var.name}/password"
  description = "Postgres password"
  type        = "SecureString"
  value       = var.postgres_admin_password
  tags        = var.tags
}
