variable "tenant" {
  description = "Name of the tenant"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{2,18}$", var.tenant))
    error_message = "Only alphanumeric characters are allowed in 'tenant', and must be 2-22 characters"
  }
}

# optional parameters
variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events of all lambdas"
  type        = number
  default     = 7
}

variable "api_key_value_users" {
  description = "Specifies the value of the API KEY for the front-office."
  type        = string
  default     = null
}

variable "api_key_value_documents" {
  description = "Specifies the value of the API KEY for the back-office."
  type        = string
  default     = null
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
