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
  type        = map(any)
  default     = {}
}

variable "integration_latency" {
  description = "Alarm for API Gateway average integration latency."
  type        = map(any)
  default     = {}
}

variable "latency" {
  description = "Alarm for API Gateway average latency."
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "A map of labels to apply to contained resources."
  type        = map(string)
  default     = {}
}
