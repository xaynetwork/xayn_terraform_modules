# AWS Budget Terraform module

Terraform module which creates budgets for services or tags on AWS.

## Usage

```hcl
module "budgets" {
  source = "../../modules/budgets"

  budget_limit       = "100"
  threshold_value    = 80
  notification_email = ["test@test.com"]
  
  budget_tags = {
    Environment = "Test"
  }
}
```
