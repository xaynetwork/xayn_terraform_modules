variable "role_name" {
  description = "Name of the task execution role"
  type        = string
}

variable "ssm_parameter_arns" {
  description = "List of parameter ARNs that are allowed to be accessed"
  type        = list(string)
}

variable "description" {
  description = "Description of the policy"
  type        = string
}

# optional parameters
variable "path" {
  description = "Path of the policy"
  type        = string
  default     = "/"
}

variable "prefix" {
  description = "Prefix for the policy name"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
