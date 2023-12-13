# AWS Postgres backup service Terraform module

Terraform module which creates a backup of a postgres database on AWS.

## Usage

```hcl
module "pg_backup" {
  source = "../../modules/service/pg_backup"

  tenant = "abc"

  container_image        = "xaynetci/example:v0.0.1"
  task_role_name         = "pg-role"
  task_role_arn          = "arn::"

  postgres_url_ssm_parameter_arn      = "arn::"
  postgres_user_ssm_parameter_arn     = "arn::"
  postgres_password_ssm_parameter_arn = "arn::"

  pg_task        = "backup"
  s3_bucket_name = "test-backup"

  # optional
  container_port     = 8000
  container_cpu      = 512
  container_memory   = 256
  alb_routing_header = "header"
  task_storage       = 50

  tags      = {
    Product = "b2b"
    User    = "provider"
  }
}
```
