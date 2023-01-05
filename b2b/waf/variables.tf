variable "ip_rate_limit" {
  description = "Maximum number of allowed request for every 5 minutes"
  type        = number
  default     = 2000
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
