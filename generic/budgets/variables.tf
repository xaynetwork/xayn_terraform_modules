variable "name" {
  description = "The name of a budget. Unique within accounts"
  type        = string
}

variable "budget_limit" {
  description = "Threshold cost for the account level"
  type        = string
}

variable "notifications" {
  description = "List budget notifications"
  type = list(object({
    comparison_operator        = string
    threshold                  = number
    threshold_type             = string
    notification_type          = string
    subscriber_email_addresses = list(string)
  }))
  default = []
}
