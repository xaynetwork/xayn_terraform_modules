variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "id" {
  description = "A unique identifier for the service"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{2,16}$", var.id))
    error_message = "Only alphanumeric characters are allowed in 'id', and must be 2-16 characters"
  }
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster"
  type        = string
}

## network
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "VPC subnet IDs to launch in the ECS service"
  type        = list(string)
}

## alb
variable "alb_listener_arn" {
  description = "ARN of the ALB listener"
  type        = string
}

variable "alb_listener_port" {
  description = "Port of the ALB listener"
  type        = number
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB"
  type        = string
}

variable "alb_algorithm_type" {
  description = "Determines how the load balancer selects targets when routing requests. The value is round_robin or least_outstanding_requests."
  type        = string
  default     = "round_robin"

  validation {
    condition     = contains(["round_robin", "least_outstanding_requests"], var.alb_algorithm_type)
    error_message = "Only round_robin or least_outstanding_requests are allowed"
  }
}

variable "alb_slow_start" {
  description = "Amount time for targets to warm up before the load balancer sends them a full share of requests. The range is 30-900 seconds or 0 to disable. The default value is 0 seconds."
  type        = number
  default     = 0
}

variable "alb_rules" {
  description = "List of path pattern rules. One rule can have up to 5 path patterns."
  type        = list(list(string))
}

## container
variable "cpu_architecture" {
  description = "CPU architecture"
  type        = string
  default     = "ARM64"
}

variable "container_image" {
  description = "Specifies value of the container image"
  type        = string
}

variable "container_cpu" {
  description = "The number of cpu units the ECS container agent reserves for the container"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "The hard limit of memory (in MiB) to present to the task"
  type        = number
  default     = 512
}

variable "container_port" {
  description = "Port of the container"
  type        = number
  default     = 8000
}

variable "enable_autoscaling" {
  description = "Determines whether to enable autoscaling for the service"
  type        = bool
  default     = true
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks to run in your service"
  type        = number
  default     = 4
}

variable "autoscaling_scheduled_actions" {
  description = "Map of autoscaling scheduled actions to create for the service"
  type        = any
  default     = {}
}

variable "environment" {
  description = "Additional environment variables to pass to the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "elasticsearch_url" {
  description = "Name of the Elasticsearch URL"
  type        = string
}

variable "elasticsearch_username" {
  description = "Name of the Elasticsearch username"
  type        = string
}

variable "elasticsearch_password_ssm_parameter_arn" {
  description = "ARN of the Elasticsearch password SSM parameter"
  type        = string
}

variable "postgres_url" {
  description = "Postgres URL"
  type        = string
}

variable "postgres_username" {
  description = "Postgres username"
  type        = string
}

variable "postgres_db" {
  description = "Name of the Postgres database"
  type        = string
}

variable "postgres_password_ssm_parameter_arn" {
  description = "ARN of the postgres password SSM parameter"
  type        = string
}

# The keep-alive default is 61. So the service timeout is higher than the ALB timeout
variable "keep_alive" {
  description = "Keep alive timeout for services in seconds"
  type        = string
  default     = "61"
}

# A "request_timeout"of "0" means that it is disabled
variable "request_timeout" {
  description = "Client request timeout for services in seconds"
  type        = string
  default     = "0"
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running"
  type        = number
  default     = 2
}

variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events of the container"
  type        = number
  default     = 7
}

variable "alarm_cpu_usage" {
  description = "Alarm for Service average CPU usage. Threshold is in percentage."
  type        = any
  default     = {}
}

variable "alarm_log_error" {
  description = "Alarm for Service error log count."
  type        = any
  default     = {}
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
