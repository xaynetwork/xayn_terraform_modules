# AWS ALB Terraform module

Terraform module which creates ALB resources on AWS.

## Usage

```hcl
module "alb" {
  source = "../../modules/alb"

  name                = "my-alb"
  vpc_id              = "vpc-abcde012"
  subnets             = ["subnet-abcde012", "subnet-bcde012a"]
  subnets_cidr_blocks = ["10.0.0.0/24", "10.0.0.1/24"]
  listener_port       = 80

  listener_default_response = {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
   }

  tags = {
    Environment = "Test"
  }
}
```
