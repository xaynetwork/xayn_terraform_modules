variable "hosted_zone_name" {
  description = "The name of the hosted zone for Route53"
  type        = string
}

variable "records" {
  description = "The name of the hosted zone for Route53"
  type = list(object({
    name    = string
    type    = string
    ttl     = number
    records = list(string)
  }))
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
