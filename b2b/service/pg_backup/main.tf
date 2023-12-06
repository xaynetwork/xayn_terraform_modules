module "secret_policy" {
  source = "../../../generic/service/secret_policy"

  role_name          = var.task_role_name
  ssm_parameter_arns = [var.postgres_url_ssm_parameter_arn, var.postgres_user_ssm_parameter_arn, var.postgres_password_ssm_parameter_arn]
  description        = "Allow PG backup service access to parameter store"
  path               = "/pg_backup/"
  prefix             = "pgbackupg"
  tags               = var.tags
}

module "task" {
  source = "../../../generic/service/task"

  name = "pgbackup"

  cpu_architecture        = var.cpu_architecture
  container_cpu           = var.container_cpu
  container_memory        = var.container_memory
  container_image         = var.container_image
  container_port          = var.container_port
  task_role_arn           = var.task_role_arn
  task_execution_role_arn = var.task_role_arn
  ephemeral_storage       = var.task_storage

  environment = {
    TASK      = var.pg_task
    S3_BUCKET = var.s3_bucket_name
    DB_NAME   = var.tenant
  }

  secrets = {
    PGPASSWORD = var.postgres_password_ssm_parameter_arn
    DB_USER    = var.postgres_user_ssm_parameter_arn
    DB_URL     = var.postgres_url_ssm_parameter_arn

  }

  log_retention_in_days = var.log_retention_in_days

  tags = var.tags
}

