variable "url_name" {
  description = "The name of the static url to redirection"
  type        = string
}

variable "hosted_zone_id" {
  description = "The ID of the hosted zone in Route 53"
  type        = string
}

variable "host_name" {
  description = "The hostname of the destination url"
  type        = string
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
