# AWS VPC Terraform module

Terraform module which creates VPC resources on AWS.

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name       = "main"
  cidr_block = "10.0.0.0/16"

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_dns = true

  # optional
  tags = {
    User    = "provider"
    Product = "b2b"
  }
}
```
