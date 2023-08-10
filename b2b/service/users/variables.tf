variable "tenant" {
  description = "Name of the tenant"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{2,22}$", var.tenant))
    error_message = "Only alphanumeric characters are allowed in 'tenant', and must be 2-22 characters"
  }
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
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

variable "elasticsearch_url" {
  description = "Name of the Elasticsearch URL"
  type        = string
}

variable "elasticsearch_username" {
  description = "Name of the Elasticsearch username"
  type        = string
}

variable "elasticsearch_index" {
  description = "Name of the Elasticsearch index"
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

variable "logging_level" {
  description = "Log level of rust apis"
  type        = string
  default     = "INFO"
}

variable "max_cois" {
  description = "The max number of calls to elasticsearch."
  type        = string
  default     = "5"
}

variable "max_documents" {
  description = "The max number of documents to return for the semantic search query."
  type        = string
  default     = "100"
}

variable "max_candidates" {
  description = "The max number of candidates to consider for the semantic search query."
  type        = string
  default     = "100"
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

variable "cpu_architecture" {
  description = "CPU architecture"
  type        = string
  default     = "X86_64"
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

variable "scheduled_scaling" {
  description = "A list of schedule configurations in order to scale the service out and in."
  type = list(object({
    schedule_out = string
    schedule_in  = string
    timezone     = string
    min_out      = number
    max_out      = number
  }))
  default = []
}

variable "max_body_size" {
  description = "The max size for bodies"
  type        = number
  default     = 4194304
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

variable "token_size" {
  description = "The size of the token for the embeddings"
  type        = string
}

variable "enable_dev_options" {
  description = "Determines if dev options are enabled."
  type        = bool
  default     = false
}

variable "sagemaker_endpoint" {
  description = "The sagemaker endpoint that will be used with this container."
  type = string
  default = null
}

variable "sagemaker_model" {
  description = "The sagemaker model that should be loaded from a multimodel sagemaker endpoint."
  type = string
  default = null
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
