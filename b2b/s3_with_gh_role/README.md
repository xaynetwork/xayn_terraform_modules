# AWS S3 bucket with role Terraform module

Terraform module which creates an S3 bucket in AWS with a role to access it from the GitHub CI. Please take into account that the S3 bucket can't be destroyed without disabling the `lifecycle.preven_destroy` flag inside this module. 

## Usage

```hcl
module "s3_with_gh_role" {
  source = "../../modules/s3_with_gh_role"

  name = "bucket-x"
  acl  = "acl-x"

  versioning = {
    enabled = true
  }

  repositories = [organization/repository-x]

  # Optional
  tags = {
    Environment = "Test"
  }
}
```
