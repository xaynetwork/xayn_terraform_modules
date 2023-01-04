# Terraform module AWS lambda role

Terraform module which creates a lambda role on AWS. The role can be used
for the authentication lambda.

## Usage

```hcl
module "role" {
  source = "../../modules/lambda/role"

  # optional
  path = "/abc/"
  prefix = "abc"
  tags   = {
    Product = "b2b"
    User    = "provider"
  }
}
```
