variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events that relate to the API gateway"
  type        = number
  default     = 7
}

variable "nlb_arn" {
  description = "The network loadbalancer that receives the proxied traffic (arn)"
  type        = string
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
