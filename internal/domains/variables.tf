variable "hosted_zone_name" {
  description = "The name of the hosted zone for Route53"
  type        = string
}

variable "records" {
  description = "List of objects of DNS records"
  type        = any
  default     = []
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
