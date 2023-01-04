# AWS NLB Terraform module

Terraform module which creates the network load balancer resource on AWS.

## Usage

```hcl
module "nlb" {
  source = "../../modules/nlb"

  name          = "my-nlb"
  vpc_id        = "vpc-abcde012"
  subnets       = ["subnet-abcde012", "subnet-bcde012a"]
  listener_port = 80
  alb_id        = "alb_id"

  tags = {
    Environment = "Test"
  }
}
```
