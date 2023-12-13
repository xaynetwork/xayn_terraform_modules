variable "tenant" {
  description = "Name of the tenant"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{2,18}$", var.tenant))
    error_message = "Only alphanumeric characters are allowed in 'tenant', and must be 2-18 characters"
  }
}

variable "task_role_name" {
  description = "IAM role that allows your Amazon ECS container task to make calls to other AWS services."
  type        = string
}

variable "task_role_arn" {
  description = "ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services."
  type        = string
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
  default     = 80
}

variable "task_storage" {
  description = "The amount of ephimeral storage configured for the task"
  type        = number
  default     = 30

}

variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events of the container"
  type        = number
  default     = 7
}

# Environmental Variables
variable "postgres_url_ssm_parameter_arn" {
  description = "ARN of the Postgres URL SSM parameter"
  type        = string
}

variable "postgres_user_ssm_parameter_arn" {
  description = "ARN of the Postgres user SSM parameter"
  type        = string
}

variable "postgres_password_ssm_parameter_arn" {
  description = "ARN of the Postgres password SSM parameter"
  type        = string
}

variable "pg_task" {
  description = "Wether to create a backup or a restore from a Postgres DB"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket where the backup/restore file will be located"
  type        = string
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
