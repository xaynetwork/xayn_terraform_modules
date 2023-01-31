variable "cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
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

# optional parameters
variable "container_port" {
  description = "Port of the container"
  type        = number
  default     = 8000
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

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running"
  type        = number
  default     = 2
}

variable "max_count" {
  description = "Max number of scalable service tasks"
  type        = number
  default     = 4
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

variable "logging_level" {
  description = "Log level of rust apis"
  type        = string
  default     = "INFO"
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

#alarms
variable "create_alarms" {
  description = "Whether to create ECS Service alarms"
  type        = bool
  default     = false
}

variable "service_cpu_threshold" {
  description = "Threshold of the CPU usage in percentage"
  type        = number
  default     = 90
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic"
  type        = string
  default     = null
}

variable "log_pattern" {
  description = "A valid CloudWatch Logs filter pattern for extracting metric data out of ingested log events"
  type        = string
  default     = "ERROR"
}

variable "log_error_threshold" {
  description = "Threshold of the documents log errors"
  type        = number
  default     = 0
}

variable "capacity_provider_strategy" {
  description = "Describes a spot instance configuration. Weights are between 0..100 and base defines the always running instances. Only one base can be 0."
  type = object({
    fargate_weight      = number
    fargate_base        = number
    fargate_spot_weight = number
    fargate_spot_base   = number
  })

  default = {
    fargate_base        = 1
    fargate_spot_base   = 0
    fargate_spot_weight = 100
    fargate_weight      = 0
  }
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
