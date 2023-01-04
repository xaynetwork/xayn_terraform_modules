# AWS Aurora Terraform module

Terraform module which creates an AWS Aurora postgres RDS. The DB secure values are stored under https://start.1password.com/open/i?a=C37D4GZQDJHGRCPCV2MUZHRSBE&v=6a4qgzoz4wgmf7a5cfzy7jbkvi&i=irs52qn32bhujgsb2ijocqsali&h=xaynag.1password.com

## Usage

```hcl
module "aurora" {
  source = "../../modules/aurora"

  name                = "my-aurora"
  vpc_id              = "vpc-abcde012"
  subnets             = ["subnet-abcde012", "subnet-bcde012a"]
  subnets_cidr_blocks = ["10.0.0.0/24", "10.0.0.1/24"]
  instance_count      = 2
  engine_version      = "13.x"

  #Scaling
  max_scaling = 1.0
  min_scaling = 0.5

  # Database Information
  db_admin_username = local.secrets.dev.username
  db_admin_password = local.secrets.dev.password

  # Optional
  tags = {
    Environment = "Test"
  }
}
```
