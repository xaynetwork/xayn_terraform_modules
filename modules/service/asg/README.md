# AWS ECS service autoscaling Terraform module

Terraform module which creates an autoscaling group for an ECS service on AWS.

## Usage

```hcl
module "asg" {
  source = "../../modules/service/asg"

  cluster_name       = "cluster-1"
  service_name       = "users-api"

  # optional
  min_tasks          = 2
  max_tasks          = 3
  target_value       = 90
  scale_in_cooldown  = 200
  scale_out_cooldown = 50
}
```
