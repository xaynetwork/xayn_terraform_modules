# AWS session manager Terraform module

Terraform module which creates a session manager resource on AWS.

## Usage

```hcl
module "ssm_user_policy" {
  source = "../../modules/ssm_user_policy"

  tags = {
    User    = "provider"
    Product = "b2b"
  }
}
```
