# AWS bastion Terraform module

Terraform module which creates a bastion host on AWS.

## Usage

```hcl
module "bastion" {
  source = "../../modules/bastion"

  vpc_id             = "vpc-1"
  subnet_id          = "subnet-1"
  egress_cidr_blocks = ["10.0.3.0/24"]
  name               = "bastion"

  # optional
  quantity = 1
  tags = {
    User    = "provider"
    Product = "b2b"
  }
}
```
