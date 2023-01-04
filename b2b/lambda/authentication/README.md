# Terraform module AWS authentication lambda

Terraform module which creates an authentication lambda on AWS.

## Usage

```hcl
module "authentication_lambda" {
  source = "../../modules/lambda/authentication"

  tenant                = "demo"

  # optional
  log_retention_in_days = 7
  tags                  = {
    Product = "b2b"
    User    = "tenant"
    Feature = "tenant_authentication"
  }
}
```
