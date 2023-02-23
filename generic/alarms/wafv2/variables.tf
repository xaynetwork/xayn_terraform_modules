variable "web_acl_name" {
  description = "Name of the WebACL"
  type        = string
}

variable "account_id" {
  description = "The account id of the metric"
  type        = string
}

variable "create_alarms" {
  description = "Whether to create ALB alarms. Defaults to true"
  type        = bool
  default     = true
}

variable "actions_enabled" {
  description = "Indicates whether or not actions should be executed during any changes to the alarm's state. Defaults to true."
  type        = bool
  default     = true
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic"
  type        = string
  default     = null
}

variable "all_requests_threshold" {
  description = "Threshold of all WAF requests"
  type        = number
  default     = 40000
}

variable "all_blocked_requests_threshold" {
  description = "Threshold of all blocked WAF requests"
  type        = number
  default     = 5000
}

variable "ip_rate_limit_threshold" {
  description = "Threshold of the WAF ip rate limit"
  type        = number
  default     = 0
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
