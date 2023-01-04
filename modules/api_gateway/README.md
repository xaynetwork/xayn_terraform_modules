# AWS API Gateway Terraform module

Terraform module that creates a Proxied API Gateway for a single tenant.
Depends on creating an authenticator before.

## Usage

```hcl
data "terraform_remote_state" "lambdas" {
  backend = "s3"

  config = {
    bucket = "xayn-infrastructure"
    key    = "stage/lambda/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "nlb" {
  backend = "s3"

  config = {
    bucket = "xayn-infrastructure"
    key    = "stage/nlb/terraform.tfstate"
    region = "eu-central-1"
  }
}

# # This should be only ran once
module "proxied_api_gateway_global" {
  source  = "../../b2b_personalization/modules/api_gateway/global"
  nlb_arn = data.terraform_remote_state.nlb.outputs.arn
  # optional

  # log_retention_in_days = 7
  tags = {
    User    = "service-provider"
    Product = "xayn-business"
  }
}

module "proxied_api_gateway" {
  source = "../../b2b_personalization/modules/api_gateway/proxy"

  tenant = "xayn2"
  # should be created per tenant
  lambda_authorizer_arn        = data.terraform_remote_state.lambdas.outputs.authorizer_arn
  lambda_authorizer_invoke_arn = data.terraform_remote_state.lambdas.outputs.invoke_authorizer_arn
  nlb_dns_name                 = data.terraform_remote_state.nlb.outputs.dns_name
  lb_vpc_link_id               = module.proxied_api_gateway_global.nlb_vpc_link_id

  # optional
  # token_name = "authorizationToken"
  # stage_name = "default"
  # log_retention_in_days = 7

  enable_usage_plan           = true
  usage_plan_api_key_id       = "api-key-1"
  usage_plan_quota_settings   = {
    limit  = 100
    offset = 0
    period = "WEEK"
  }
  usage_plan_throttle_settings = {
    burst_limit = 100
    rate_limit  = 25
  }

  tags = {
    User    = "service-provider"
    Product = "xayn-business"
  }

  depends_on = [
    module.proxied_api_gateway_global
  ]
}
```
