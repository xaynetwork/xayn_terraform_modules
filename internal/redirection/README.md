# AWS Terraform module for redirectioning websites with S3

Terraform module which creates an S3 bucket that will be used to host a static website to redirection to a certain website.

## Usage

```hcl
module "redirection" {
  source = "../../modules/redirection"

  url_name       = "example.xayn.com"
  hosted_zone_id = "my_hosted_zone"
  host_name      = "emaple.example.com/example"

  # Optional
  tags = {
    Environment = "Test"
  }
}
```
