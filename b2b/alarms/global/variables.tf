variable "slack_url" {
  description = "Slack URL"
  type        = string
}

variable "create_alb_alarms" {
  description = "Whether to create ALB alarms"
  type        = bool
  default     = true
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB"
  type        = string
  default     = null
}

variable "alb_services_5xx_error_threshold" {
  description = "Threshold of the ALB services HTTP-5XX errors"
  type        = number
  default     = 0
}

variable "alb_5xx_error_threshold" {
  description = "Threshold of the ALB HTTP-5XX errors"
  type        = number
  default     = 0
}

variable "alb_4xx_error_threshold" {
  description = "Threshold of the ALB HTTP-4XX errors"
  type        = number
  default     = 0
}

variable "create_waf_alarms" {
  description = "Whether to create WAF alarms"
  type        = bool
  default     = true
}

variable "web_acl" {
  description = "Name of the WebALC"
  type        = string
  default     = null
}

variable "waf_all_requests_threshold" {
  description = "Threshold of all WAF requests"
  type        = number
  default     = 40000
}

variable "waf_all_blocked_requests_threshold" {
  description = "Threshold of all blocked WAF requests"
  type        = number
  default     = 5000
}

variable "waf_ip_rate_limit_threshold" {
  description = "Threshold of the WAF ip rate limit"
  type        = number
  default     = 0
}

variable "create_aurora_alarms" {
  description = "Whether to create Aurora alarms"
  type        = bool
  default     = true
}

variable "aurora_cluster_name" {
  description = "Name of the aurora cluster"
  type        = string
  default = null
}

variable "aurora_read_latency_threshold" {
  description = "Threshold of the average Aurora read latency in milliseconds"
  type        = number
  default     = 10
}

variable "aurora_write_latency_threshold" {
  description = "Threshold of the average Aurora write latency in milliseconds"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
