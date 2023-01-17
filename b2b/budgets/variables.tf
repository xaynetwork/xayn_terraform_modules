variable "budget_limit" {
  description = "Threshold cost for the account level"
  type        = string
}

variable "threshold_value" {
  description = "Threshold in percentage for notifying"
  type        = number
  default     = 80
}

variable "notification_emails" {
  description = "List of emails to send the budget notifications"
  type        = list(string)
}
