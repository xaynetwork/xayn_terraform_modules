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
  description = "Name of the Postgres username SSM parameter"
  type        = string
}

variable "password_ssm_parameter_name" {
  description = "Name of the Postgres password SSM parameter"
  type        = string
}

variable "url_ssm_parameter_name" {
  description = "Name of the Postgres URL SSM parameter"
  type        = string
}

variable "skip_delete" {
  description = "Set this to true to prevent the deletion of the real resource. It must be deleted manually. Can be overridden in the CLI."
  type        = bool
  default     = true
}

variable "aws_profile" {
  description = "AWS Profile with which the provisioner should be executed"
  type        = string
}
