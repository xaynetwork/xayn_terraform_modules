variable "arn_suffix" {
  description = "The ALB ARN suffix for use with CloudWatch Metrics."
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

variable "services_http_5xx_error" {
  description = "Alarm for ALB services HTTP-5XX errors."
  type        = any
  default     = {}
}

variable "http_5xx_error" {
  description = "Alarm for ALB HTTP-5XX errors."
  type        = any
}

variable "http_4xx_error" {
  description = "Alarm for ALB HTTP-4XX errors."
  type        = any
}

variable "tags" {
  description = "A map of labels to apply to contained resources."
  type        = map(string)
  default     = {}
}
