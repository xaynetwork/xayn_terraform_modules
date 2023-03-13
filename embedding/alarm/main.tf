data "aws_caller_identity" "current" {}
module "alarm" {
  providers = {
    aws = aws.monitoring-account
  }
  source = "../../generic/alarms/composite"

  create_alarm = var.create_alarm
  name         = "${data.aws_caller_identity.current.account_id}_nc_system"
  description  = "One or more incidents on the NC system. Action required. Check dashboard for more insights."

  rule = join(" OR ", [for arn in var.alarm_arns : "ALARM(${arn})"])

  ok_actions    = var.ok_actions
  alarm_actions = var.alarm_actions

  tags = var.tags
}
