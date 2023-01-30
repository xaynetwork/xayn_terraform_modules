variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events that relate to the API gateway"
  type        = number
  default     = 7
}

variable "nlb_arn" {
  description = "The network load balancer that receives the proxied traffic (arn)"
  type        = string
}

variable "tenant" {
  description = "Name of the tenant"
  type        = string
}

variable "token_name" {
  description = "Name of the authorization token (header)"
  type        = string
  default     = "authorizationToken"
}

variable "stage_name" {
  description = "Name of the API stage"
  type        = string
  default     = "default"
}

variable "lambda_authorizer_arn" {
  description = "Specifies the ARN for the lambda function that authorizes that tenant"
  type        = string
}

variable "lambda_authorizer_invoke_arn" {
  description = "Specifies the ARN to invoke the lambda function that authorizes that tenant"
  type        = string
}

variable "nlb_dns_name" {
  description = "The network load balance`r that receives the proxied traffic (dns_name)"
  type        = string
}

variable "enable_usage_plan" {
  description = "Enable usage plan"
  type        = bool
  default     = false
}

variable "usage_plan_api_key_id" {
  description = "ID of the API key"
  type        = string
  default     = ""
}

variable "usage_plan_quota_settings" {
  description = "Maximum number of requests that can be made in a given time period"
  type = object({
    limit  = number
    offset = number
    period = string
  })
  default = null

  validation {
    condition     = var.usage_plan_quota_settings == null ? true : contains(["DAY", "WEEK", "MONTH"], var.usage_plan_quota_settings.period)
    error_message = "Only DAY, WEEK or MONTH are allowed"
  }
}

variable "usage_plan_throttle_settings" {
  description = "API request burst and rate (rps) limit"
  type = object({
    burst_limit = number
    rate_limit  = number
  })
  default = {
    burst_limit = 100
    rate_limit  = 25
  }
}

variable "web_acl_arn" {
  description = "The ARN of the web ACL"
  type        = string
  default     = null
}

variable "default_method_throttle_settings" {
  description = "API request burst and rate (rps) limit for all methods, including those that don't require an API key"
  type = object({
    burst_limit = number
    rate_limit  = number
  })
  default = null
}

variable "create_alarms" {
  description = "Whether to create API Gateway alarms"
  type        = bool
  default     = false
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic"
  type        = string
  default     = null
}

variable "http_5xx_error_threshold" {
  description = "Threshold of the API Gateway HTTP 5XX errors"
  type        = number
  default     = 0
}

variable "integration_latency_threshold" {
  description = "Threshold of the average API Gateway integration latency in milliseconds"
  type        = number
  default     = 250
}

variable "latency_threshold" {
  description = "Threshold of the average API Gateway latency in milliseconds"
  type        = number
  default     = 300
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
