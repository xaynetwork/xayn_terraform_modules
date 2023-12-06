variable "name" {
  description = "Name of the ECS service"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9\\-]{2,29}$", var.name))
    error_message = "Only alphanumeric characters and hyphens allowed in 'name', and must be 2-29 characters"
  }
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

# optional parameters
## task
variable "task_execution_role_arn" {
  description = "ARN of the task execution role"
  type        = string
  default     = null
}

variable "task_role_arn" {
  description = "ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services."
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

  validation {
    condition     = contains(["X86_64", "ARM64"], var.cpu_architecture)
    error_message = "Only X86_64 or ARM64 are allowed"
  }
}

variable "environment" {
  description = "The environment variables to pass to a container"
  type        = map(string)
  default     = {}
}

variable "ephemeral_storage" {
  description = "Ephemeral storage size if the task requires a specific amount of ephemeral storage"
  type        = number
  default     = null
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

## other
variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
