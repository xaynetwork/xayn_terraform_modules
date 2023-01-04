resource "aws_budgets_budget" "budget_account" {
  for_each     = var.budget_tags
  name         = "Monthly Budget ${each.key} ${each.value}"
  budget_type  = "COST"
  limit_amount = var.budget_limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "TagKeyValue"
    values = ["${each.key}${"$"}${each.value}"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.threshold_value
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.notification_email
  }
}
