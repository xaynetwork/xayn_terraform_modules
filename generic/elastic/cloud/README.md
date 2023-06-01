# Elastic Cloud Terraform module

Terraform module which creates a Elastic Cloud deployment.

## Usage

```hcl
module "es" {
  source = "../../modules/es"

  name                   = "test"
  es_version             = "8.4.3"
  deployment_template_id = "aws-general-purpose-v2"

  #AWS Resources
  vpce_id            = "vpce-abcd123"

  # Optional
  hot_tier_memory     = 10
  hot_tier_memory_max = 15

  tags = {
    Environment = "Test"
  }
}
```
