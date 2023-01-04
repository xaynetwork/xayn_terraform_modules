# AWS ECS task execution role Terraform module

Terraform module which creates a task execution role resource for an ECS task on AWS.

## Usage

```hcl
module "role" {
  source = "../../modules/service/role"

  task_name          = "UserApi"
  description        = "Description of the role"

  # optional
  path      = "/abc/"
  prefix    = "abc"
  tags      = {
    Product = "b2b"
    User    = "provider"
  }
}
```
