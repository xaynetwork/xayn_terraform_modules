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

# cloudwatch alarms
module "services_http_5xx_error_alarm" {
  count   = var.create_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "alb_services_5xx_error"
  alarm_description   = "Number of ALB services HTTP-5XX errors > ${var.services_http_5xx_error_threshold}. It may indicate an issue within the ECS services."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.services_http_5xx_error_threshold
  period              = 60
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_5XX_Count"
  statistic   = "Sum"

  dimensions = {
    LoadBalancer = aws_lb.this.arn_suffix
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

module "http_5xx_error_alarm" {
  count   = var.create_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "alb_5xx_error"
  alarm_description   = "Number of ALB HTTP-5XX errors > ${var.http_5xx_error_threshold}. It may indicate an integration issue with the ECS services."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.http_5xx_error_threshold
  period              = 60
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_5XX_Count"
  statistic   = "Sum"

  dimensions = {
    LoadBalancer = aws_lb.this.arn_suffix
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

module "http_4xx_error_alarm" {
  count   = var.create_alarms ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.2.1"

  alarm_name          = "alb_4xx_error"
  alarm_description   = "Number of ALB HTTP-4XX errors > ${var.http_4xx_error_threshold}. It may indicate an integration issue with the NLB or with the ECS services."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = var.http_4xx_error_threshold
  period              = 60
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_4XX_Count"
  statistic   = "Sum"

  dimensions = {
    LoadBalancer = aws_lb.this.arn_suffix
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}
