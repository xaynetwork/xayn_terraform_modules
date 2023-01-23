# AWS Terraform module for creating an AWS SSO permission set

Terraform module which creates a SSO permission set with a customer created policy.

## Usage

```hcl
module "sso" {
  source = "../../modules/sso_permission"

  permission_name  = "permission_x"
  policy_name      = "policy_x"

  actions   = ["s3:...",..]
  resources = ["arn:aws:s3:::*",.. ]

  # Optional
  tags = {
    Environment = "Test"
  }
}
```
