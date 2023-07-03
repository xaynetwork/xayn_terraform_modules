variable "domain_name" {
  description = "The name of the domain to create the certificate for"
  type        = string
}

variable "zone_name" {
  description = "Name of the zone where to create the records"
  type        = string
}
