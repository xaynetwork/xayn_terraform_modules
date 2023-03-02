module "security_group" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group?ref=v4.16.0"

  name        = "${var.name}-sg"
  description = "Security group of the ECS services ALB"
  vpc_id      = var.vpc_id

  # client ip is the ip of the nlb living in the same private subnet as the alb
  ingress_cidr_blocks = var.subnets_cidr_blocks
  ingress_with_cidr_blocks = [
    {
      from_port   = var.listener_port
      to_port     = var.listener_port
      protocol    = "tcp"
      description = "Allow NLB inbound traffic on ALB listener"

  }]
  egress_cidr_blocks = var.subnets_cidr_blocks
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow ALB outbound traffic to instances in the private subnets"
  }]

  tags = var.tags
}

resource "aws_lb" "this" {
  name                       = var.name
  subnets                    = var.subnets
  security_groups            = [module.security_group.security_group_id]
  internal                   = true
  drop_invalid_header_fields = true
  tags                       = var.tags
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.this.id
  port              = var.listener_port
  protocol          = "HTTP"
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-listener"
    }
  )

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = var.listener_default_response.content_type
      message_body = var.listener_default_response.message_body
      status_code  = var.listener_default_response.status_code
    }
  }
}

resource "aws_lb_listener_rule" "health_check" {
  listener_arn = aws_lb_listener.listener.arn

  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "200"
    }
  }

  condition {
    path_pattern {
      values = [var.health_check_path]
    }
  }

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

  arn_suffix = aws_lb.this.arn_suffix

  services_http_5xx_error = var.alarm_services_http_5xx_error
  http_5xx_error          = var.alarm_http_5xx_error
  http_4xx_error          = var.alarm_http_4xx_error

  tags = var.tags
}
