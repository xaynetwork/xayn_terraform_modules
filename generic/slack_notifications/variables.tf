variable "slack_url" {
  description = "Slack URL"
  type        = string
}

variable "additional_subscriptions" {
  description = "Additional subscriptions that piggyback on that slack sns topic. Protocol: sqs, sms, lambda, firehose, application, email, email-json, http, https"
  type = list(object({
    protocol = string
    endpoint = string
  }))
  default = []
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
