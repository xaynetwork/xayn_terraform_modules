module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.7.0"

  name        = var.name
  name_prefix = var.name_prefix

  load_balancer_type = "application"
  internal           = var.internal

  vpc_id  = var.vpc_id
  subnets = var.subnets

  security_groups      = var.security_groups
  security_group_rules = var.security_group_rules

  drop_invalid_header_fields = var.drop_invalid_header_fields

  http_tcp_listeners = var.http_tcp_listeners

  tags = var.tags
}

# CloudWatch alarms
data "aws_caller_identity" "current" {}
module "alarms" {
  providers = {
    aws = aws.monitoring-account
  }
  source = "../../generic/alarms/alb"

  account_id = data.aws_caller_identity.current.account_id
  prefix     = "${data.aws_caller_identity.current.account_id}_"

  arn_suffix = module.alb.lb_arn_suffix

  http_5xx_error = var.alarm_http_5xx_error
  http_4xx_error = var.alarm_http_4xx_error

  tags = var.tags
}
