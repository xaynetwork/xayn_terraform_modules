# AWS RDS Terraform module

Terraform module which creates the postgres RDS on AWS. The DB secure values are stored under https://start.1password.com/open/i?a=C37D4GZQDJHGRCPCV2MUZHRSBE&v=6a4qgzoz4wgmf7a5cfzy7jbkvi&i=irs52qn32bhujgsb2ijocqsali&h=xaynag.1password.com

## Usage

```hcl
module "rds" {
  source = "../../modules/rds"

  name            = "my-alb"
  vpc_id          = "vpc-abcde012"
  subnets         = ["subnet-abcde012", "subnet-bcde012a"]

  # Database Information
  postgres_admin_username = local.secrets.dev.username
  postgres_admin_password = local.secrets.dev.password

  # Optional
  tags = {
    Environment = "Test"
  }
}
```
