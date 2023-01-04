resource "aws_lb_target_group" "target_group" {
  name        = "alb-${var.name}-tg"
  target_type = "alb"
  port        = var.listener_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id

  health_check {
    path = var.alb_health_check_path
  }

  tags = var.tags
}

resource "aws_lb_target_group_attachment" "target_group_attachment" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = var.alb_id
  port             = var.listener_port
}

resource "aws_lb" "this" {
  name               = var.name
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnets
  tags               = var.tags
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.this.id
  port              = var.listener_port
  protocol          = "TCP"
  tags              = var.tags

  default_action {
    target_group_arn = aws_lb_target_group.target_group.id
    type             = "forward"
  }
}
