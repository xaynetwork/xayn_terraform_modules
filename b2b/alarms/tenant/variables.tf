variable "sns_topic_arn" {
  description = "ARN of the SNS topic"
  type        = string
}

variable "create_api_gateway_alarms" {
  description = "Whether to create API Gateway alarms"
  type        = bool
  default     = true
}

variable "api_gateway_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = null
}

variable "api_gateway_5xx_error_threshold" {
  description = "Threshold of the API Gateway HTTP 5XX errors"
  type        = number
  default     = 0
}

variable "api_gateway_integration_latency_threshold" {
  description = "Threshold of the average API Gateway integration latency in milliseconds"
  type        = number
  default     = 250
}

variable "api_gateway_latency_threshold" {
  description = "Threshold of the average API Gateway latency in milliseconds"
  type        = number
  default     = 300
}

variable "create_ecs_alarms" {
  description = "Whether to create ECS alarms"
  type        = bool
  default     = true
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = null
}

variable "ecs_users_service_name" {
  description = "Name of the users service"
  type        = string
  default     = null
}

variable "ecs_users_log_group_name" {
  description = "Name of the users log group"
  type        = string
  default     = null
}

variable "users_service_cpu_threshold" {
  description = "Threshold of the CPU usage in percentage"
  type        = number
  default     = 90
}

variable "ecs_users_log_pattern" {
  description = "A valid CloudWatch Logs filter pattern for extracting metric data out of ingested log events"
  type        = string
  default     = "ERROR"
}

variable "ecs_users_log_error_threshold" {
  description = "Threshold of the users log errors"
  type        = number
  default     = 0
}

variable "ecs_documents_service_name" {
  description = "Name of the documents service"
  type        = string
  default     = null
}

variable "ecs_documents_log_group_name" {
  description = "Name of the documents log group"
  type        = string
  default     = null
}

variable "documents_service_cpu_threshold" {
  description = "Threshold of the CPU usage in percentage"
  type        = number
  default     = 90
}

variable "ecs_documents_log_pattern" {
  description = "A valid CloudWatch Logs filter pattern for extracting metric data out of ingested log events"
  type        = string
  default     = "ERROR"
}

variable "ecs_documents_log_error_threshold" {
  description = "Threshold of the documents log errors"
  type        = number
  default     = 0
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
