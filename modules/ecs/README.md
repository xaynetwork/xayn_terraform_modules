# AWS ECS Terraform module

Terraform module which creates ECS resources on AWS.

## Usage

```hcl
module "ecs" {
  source = "../../modules/ecs"

  name = "test"

  # Optional
  tags    = {
    Environment = "Test"
  }
}
```
