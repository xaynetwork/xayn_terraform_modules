variable "hosted_zone_name" {
  description = "The name of the hosted zone for Route53"
  type        = string
}

variable "records" {
  description = "The name of the hosted zone for Route53"
  type = object({
    record_name    = string
    record_type    = string
    record_ttl     = string
    record_records = list(string)
  })
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
