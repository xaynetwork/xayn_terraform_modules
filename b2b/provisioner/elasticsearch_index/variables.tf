variable "tenant" {
  description = "Name of the tenant"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{2,18}$", var.tenant))
    error_message = "Only alphanumeric characters are allowed in 'tenant', and must be 2-18 characters"
  }
}

variable "function_arn" {
  description = "ARN of the lambda"
  type        = string
}

variable "username_ssm_parameter_name" {
  description = "Name of the Elasticsearch username SSM parameter"
  type        = string
}

variable "password_ssm_parameter_name" {
  description = "Name of the Elasticsearch password SSM parameter"
  type        = string
}

variable "url_ssm_parameter_name" {
  description = "Name of the Elasticsearch URL SSM parameter"
  type        = string
}

variable "aws_profile" {
  description = "AWS Profile with which the provisioner should be executed"
  type        = string
}

variable "embedding_dims" {
  description = " Number of vector dimensions"
  type        = number
  default     = 384
}
