variable "name" {
  description = "Name of the ECS service"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9\\-]{2,29}$", var.name))
    error_message = "Only alphanumeric characters and hyphens allowed in 'name', and must be 2-29 characters"
  }
}

variable "cluster_id" {
  description = "ID of the ECS cluster"
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

## task
variable "container_image" {
  description = "Specifies value of the container image"
  type        = string
}

variable "container_port" {
  description = "Port of the container"
  type        = number
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

variable "alb_health_path" {
  description = "The health check path of the service"
  type        = string
}

variable "alb_routing_path_pattern" {
  description = "The path patterns that needs to match in order to route request to this service"
  type        = list(string)
}

# optional parameters
## task
variable "task_execution_role_arn" {
  description = "ARN of the task execution role"
  type        = string
  default     = ""
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

variable "cpu_architecture" {
  description = "CPU architecture"
  type        = string
  default     = "X86_64"
}

variable "environment" {
  description = "The environment variables to pass to a container"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "An object representing the secret to expose to the container"
  type        = map(string)
  default     = {}
}

variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events of the container"
  type        = number
  default     = 7
}

## service
variable "platform_version" {
  description = "Version of the Fargate platform"
  type        = string
  default     = "1.4.0"
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with"
  type        = list(string)
  default     = []
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running"
  type        = number
  default     = 2
}

variable "deployment_maximum_percent" {
  description = "Upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment"
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "Lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment"
  type        = number
  default     = 100
}

variable "deployment_circuit_breaker" {
  description = "Whether to enable the deployment circuit breaker logic for the service"
  type = object({
    enable   = bool
    rollback = bool
  })
  default = {
    enable   = true
    rollback = true
  }
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown"
  type        = number
  default     = 30
}

## other
variable "alb_routing_header" {
  description = "If set, the path patterns and the X-Tenant-Id header must match in order to route request to this service"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
