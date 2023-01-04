# Elasticsearch Terraform module

Terraform module which creates the Elasticsearch.
Export API Key is located: https://start.1password.com/open/i?a=C37D4GZQDJHGRCPCV2MUZHRSBE&v=6teygc45uzab5citwbdhkfwel4&i=2uocmbv7kqjuazwh2nxyqwq4nm&h=xaynag.1password.com under terraform section.

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
