variable "create_alarms" {
  description = "Whether to create ALB alarms"
  type        = bool
  default     = false
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic"
  type        = string
  default     = null
}

variable "services_http_5xx_error_threshold" {
  description = "Threshold of the ALB services HTTP-5XX errors"
  type        = number
  default     = 0
}

variable "http_5xx_error_threshold" {
  description = "Threshold of the ALB HTTP-5XX errors"
  type        = number
  default     = 0
}

variable "http_4xx_error_threshold" {
  description = "Threshold of the ALB HTTP-4XX errors"
  type        = number
  default     = 0
}

variable "lb_arn_suffix" {
  description = "The Load Balancer ARN suffix for use with CloudWatch Metrics."
  type = string
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
