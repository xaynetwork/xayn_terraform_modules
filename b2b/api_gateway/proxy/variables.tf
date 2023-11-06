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

variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events that relate to the API gateway"
  type        = number
  default     = 7
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
  description = "The network load balancer that receives the proxied traffic (dns_name)"
  type        = string
}

variable "nlb_vpc_link_id" {
  description = "The load balancer vpc link id that in takes the incoming request (generated by global)"
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

variable "enable_access_logs" {
  description = "Enable API access logs"
  type        = bool
  default     = false
}

variable "access_logs_format" {
  description = "API access log format setting"
  type        = map(string)
  default = {
    "requestId"                     = "$context.requestId",
    "waf-error"                     = "$context.waf.error",
    "waf-status"                    = "$context.waf.status",
    "waf-latency"                   = "$context.waf.latency",
    "waf-response"                  = "$context.wafResponseCode",
    "authenticate-error"            = "$context.authenticate.error",
    "authenticate-status"           = "$context.authenticate.status",
    "authenticate-latency"          = "$context.authenticate.latency",
    "authorize-error"               = "$context.authorize.error",
    "authorize-status"              = "$context.authorize.status",
    "authorize-latency"             = "$context.authorize.latency",
    "integration-error"             = "$context.integration.error",
    "integration-status"            = "$context.integration.status",
    "integration-latency"           = "$context.integration.latency",
    "integration-requestId"         = "$context.integration.requestId",
    "integration-integrationStatus" = "$context.integration.integrationStatus",
    "response-latency"              = "$context.responseLatency",
    "status"                        = "$context.status"
  }
}

variable "metrics_enabled_api" {
  description = "Whether to enable dimensions for metrics in the API Gateway"
  type        = bool
  default     = false
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

variable "enable_rag_endpoint" {
  description = "Enable RAG integration."
  type        = bool
  default     = false
}

variable "rag_integration_config" {
  description = "RAG integration configuration."
  type        = any
  default     = {}
  # example
  # {
  #   invoke_arn = ""
  #   function_name = ""
  #   throttling = {
  #     burst_limit = 1
  #     rate_limit  = 2
  #   }
  # }
}

variable "alarm_http_5xx_error" {
  description = "Alarm for API Gateway HTTP-5XX errors."
  type        = any
  default     = {}
}

variable "alarm_latency" {
  description = "Alarm for API Gateway p90 latency."
  type        = any
  default     = {}
}

variable "alarm_latency_by_method" {
  description = "Alarm for API Gateway p90 latency by method and resource."
  type        = any
  default     = {}
}

variable "alarm_error_rate" {
  description = "Alarm for an increased error rate on the API Gateway."
  type        = any
  default     = {}
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
