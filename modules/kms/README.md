# AWS KMS Terraform module

Terraform module which creates a KMS on AWS.

## Usage

```hcl
module "kms" {
  source = "../../modules/kms"

  name            = "kms-1"

  # Optional
  tags = {
    Environment = "Test"
  }
}
```
