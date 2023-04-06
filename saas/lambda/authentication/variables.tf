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
