variable "name" {
  description = "The name for the ALB resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnets" {
  description = "The IDs of the subnets to associate with the ALB"
  type        = list(string)
}

variable "subnets_cidr_blocks" {
  description = "The CIDR subnet blocks of the security group"
  type        = list(string)
}

variable "listener_port" {
  description = "Value of the port for the listener"
  type        = number
}

variable "listener_default_response" {
  description = "Default response if no rule matches"
  type = object({
    content_type = string
    message_body = string
    status_code  = string
  })
  default = {
    content_type = "text/plain"
    message_body = "Not Found"
    status_code  = "404"
  }
}

variable "health_check_path" {
  description = "The path of the ALB health check"
  type        = string
  default     = "/health"
}

variable "create_alarms" {
  description = "Whether to create ALB alarms"
  type        = bool
  default     = true
}

variable "actions_enabled" {
  description = "Indicates whether or not actions should be executed during any changes to the alarm's state. Defaults to true."
  type        = bool
  default     = true
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

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
