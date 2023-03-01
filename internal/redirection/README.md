# AWS Terraform module for redirecting websites with S3

Terraform module which creates a S3 bucket that will be used for redirection to a certain website.

## Usage

```hcl
module "redirection" {
  providers = {
    aws.us-east-1 = aws.us-east-1
  }
  source = "../../modules/redirection"

  domain_name    = "example.xayn.com"
  hosted_zone_id = "my_hosted_zone"
  host_name      = "example.example.com/example"

  # Optional
  tags = {
    Environment = "Test"
  }
}
```
