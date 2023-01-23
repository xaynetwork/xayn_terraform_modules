# AWS Terraform module for creating an AWS SSO permission set

Terraform module which creates a SSO permission set with a customer created policy.

## Usage

```hcl
module "sso" {
  source = "../../modules/sso_permission"

  permission_name  = "permission_x"
  sso_instance_arn = "arn::::"
  duration         = "10h"
  policy_name      = "policy_x"

  # Optional
  tags = {
    Environment = "Test"
  }
}
```
