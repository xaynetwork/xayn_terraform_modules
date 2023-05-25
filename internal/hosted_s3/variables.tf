variable "domain_name" {
  description = "The name of domain that is used for the redirection"
  type        = string
}

variable "host_name" {
  description = "Name of the host where requests are redirected"
  type        = string
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
