variable "web_acl_name" {
  description = "The name of web ALC for use with CloudWatch Metrics."
  type        = string
}

variable "web_acl_region" {
  description = "Specifies the AWS region of the WAF."
  type        = string
}

variable "account_id" {
  description = "Specifies the ID of the account where the metric is located."
  type        = string
}

variable "prefix" {
  description = "Specifies a prefix for all alarm names."
  type        = string
  default     = ""
}

variable "all_requests" {
  description = "Alarm for WAF ALL requests."
  type        = map(any)
  default     = {}
}

variable "all_blocked_requests" {
  description = "Alarm for WAF ALL blocked requests."
  type        = map(any)
  default     = {}
}

variable "ip_rate_limit" {
  description = "Alarm for WAF ip rate limit."
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "A map of labels to apply to contained resources."
  type        = map(string)
  default     = {}
}
