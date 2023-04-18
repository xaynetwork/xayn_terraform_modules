variable "dynamodb_table_arn" {
  description = "The ARN of the tenant table to provide read access to."
  type = string
}

variable "dynamodb_table_name" {
  description = "The Name of the tenant table to provide read access to."
  type = string
}


# optional parameters
variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events of all lambdas"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
