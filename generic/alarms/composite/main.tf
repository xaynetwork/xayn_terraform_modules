resource "aws_cloudwatch_composite_alarm" "this" {
  count = var.create_alarm ? 1 : 0

  alarm_description = var.description
  alarm_name        = var.name

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions

  alarm_rule = var.rule

  tags = var.tags
}
