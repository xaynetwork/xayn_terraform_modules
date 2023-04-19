variable "name" {
  description = "Name of the ElasticSearch to Cloudwatch metric exporter"
  type        = string
}

variable "cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "VPC subnet IDs to launch in the ECS service"
  type        = list(string)
}

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

variable "execution_role_arn" {
  description = "ARN of the execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the task role"
  type        = string
}

variable "task_cpu" {
  description = "The number of cpu units the ECS container agent reserves for the task"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "The hard limit of memory (in MiB) to present to the task"
  type        = number
  default     = 512
}

variable "task_cpu_architecture" {
  description = "CPU architecture"
  type        = string
  default     = "X86_64"

  validation {
    condition     = contains(["X86_64", "ARM64"], var.task_cpu_architecture)
    error_message = "Only X86_64 or ARM64 are allowed"
  }
}

variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events of the container"
  type        = number
  default     = 7
}

# elasticsearch exporter container settings
variable "es_exporter_name" {
  description = "Name of the ECS service"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9\\-]{2,29}$", var.es_exporter_name))
    error_message = "Only alphanumeric characters and hyphens allowed in 'name', and must be 2-29 characters"
  }

  default = "es-exporter"
}

variable "es_exporter_container_image" {
  description = "Specifies value of the container image"
  type        = string
}

variable "es_exporter_container_port" {
  description = "Port of the container"
  type        = number
  default     = 9114
}

variable "es_exporter_environment" {
  description = "The environment variables to pass to a container"
  type        = map(string)
  default     = {}
}

variable "es_exporter_secrets" {
  description = "An object representing the secret to expose to the container"
  type        = map(string)
  default     = {}
}

variable "es_exporter_args" {
  description = "Additional cli args"
  type        = list(string)
  default     = []
}

# prometheus exporter container settings
variable "pc_exporter_name" {
  description = "Name of the ECS service"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9\\-]{2,29}$", var.pc_exporter_name))
    error_message = "Only alphanumeric characters and hyphens allowed in 'name', and must be 2-29 characters"
  }

  default = "pc-exporter"
}

variable "pc_exporter_container_image" {
  description = "Specifies value of the container image"
  type        = string
}

variable "pc_exporter_environment" {
  description = "The environment variables to pass to a container"
  type        = map(string)
  default     = {}
}

# other
variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
