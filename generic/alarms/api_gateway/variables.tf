variable "api_name" {
  description = "The API Gateway name for use with CloudWatch Metrics."
  type        = string
}

variable "api_stage" {
  description = "The API Gateway stage for use with CloudWatch Metrics. Defaults to 'default'."
  type        = string
  default     = "default"
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

variable "http_5xx_error" {
  description = "Alarm for API Gateway HTTP-5XX errors."
  type        = any
  default     = {}
}

variable "latency" {
  description = "Alarm for API Gateway p90 latency."
  type        = any
  default     = {}
}

variable "latency_by_method" {
  description = "Alarm for API Gateway p90 latency by Method."
  type        = any
  default     = {}
}

variable "error_rate" {
  description = "Alarm for an increased error rate on the API Gateway."
  type        = any
  default     = {}
}

variable "tags" {
  description = "A map of labels to apply to contained resources."
  type        = map(string)
  default     = {}
}
