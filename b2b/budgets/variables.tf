variable "budget_limit" {
  description = "Threshold cost for the account level"
  type        = string
}

variable "budget_tags" {
  description = "List of AWS Tags to be monitored in terms of costs"
  type        = map(string)
  default     = {}
}

variable "threshold_value" {
  description = "Threshold in percentage for notifying"
  type        = number
  default     = 80
}

variable "notification_email" {
  description = "List of emails to send the budget notifications"
  type        = list(string)
}
