# AWS secrets policy Terraform module

Terraform module which creates a secret policy resource for an ECS service on AWS.

## Usage

```hcl
module "secret_policy" {
  source = "../../modules/service/secret_policy"

  role_name          = "EcsTaskExecutionRole"
  ssm_parameter_arns = ["arn::1", "arn::2"]
  description        = "Description of the policy"

  # optional
  path      = "/abc/"
  prefix    = "abc"
  tags      = {
    Product = "b2b"
    User    = "provider"
  }
}
```
