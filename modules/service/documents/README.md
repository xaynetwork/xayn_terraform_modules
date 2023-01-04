# AWS documents ECS service Terraform module

Terraform module which creates a documents ECS service on AWS.

## Usage

```hcl
module "documents" {
  source = "../../modules/service/documents"

  tenant = "abc"

  cluster_name = "cluster-1"
  cluster_id   = "cluster-1"
  vpc_id       = "vpc-1"
  subnet_ids   = ["subnet-1"]

  container_image        = "xaynetci/example:v0.0.1"
  elasticsearch_url      = "https://"
  elasticsearch_username = "elastic"
  elasticsearch_index    = "index"

  elasticsearch_password_ssm_parameter_arn = "arn::"
  postgres_url_ssm_parameter_arn           = "arn::"

  alb_listener_arn      = "arn::"
  alb_listener_port     = 80
  alb_security_group_id = "alb-sg-id"

  # optional
  container_port     = 8000
  container_cpu      = 512
  container_memory   = 256
  alb_routing_header = "header"

  tags      = {
    Product = "b2b"
    User    = "provider"
  }
}
```
