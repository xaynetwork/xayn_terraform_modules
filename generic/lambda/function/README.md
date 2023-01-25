# Terraform module AWS lambda function

Terraform module which creates a lambda function on AWS.

## Usage

```hcl
module "function" {
  source = "../function"

  function_name    = "handler"
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  source_code_hash = "hash"
  output_path      = "index.zip"
  lambda_role_arn  = var.lambda_role_arn

  # optional
  log_retention_in_days = 7
  tags                  = {
    Product = "b2b"
    User    = "provider"
  }
}
```
