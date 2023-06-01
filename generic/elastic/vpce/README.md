# AWS Elastic Cloud VPC endpoint Terraform module

Terraform module which creates VPC endpoint for Elastic Cloud on AWS.

## Usage

```hcl
module "vpce" {
  source = "../../modules/vpce"

  name   = "main"
  vpc_id = "vpc-abcde012"

  subnets_cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"]

  # optional
  tags = {
    User    = "service-provider"
    Product = "xayn-business"
  }
}
```
