# AWS EC2 Terraform module

Terraform module which creates an EC2 resource on AWS.

## Usage

```hcl
module "ec2" {
  source = "../../modules/ec2"

  role_name = "RoleName"
  subnet_id = "subnet-1"
  name      = "bastion"

  # optional
  quantity               = 1
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-1"]
  tags = {
    User    = "provider"
    Product = "b2b"
  }
}
```
