variable "domain_name" {
  description = "The name of domain that is used for the redirection"
  type        = string
}

variable "hosted_zone_id" {
  description = "The ID of the hosted zone in Route 53"
  type        = string
}

variable "host_name" {
  description = "Name of the host where requests are redirected"
  type        = string
}

variable "apex_domain" {
  description = "Name of apex if the root level is the one being redirected"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
