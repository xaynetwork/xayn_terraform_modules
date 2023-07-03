variable "domain_name" {
  description = "The name of the domain to create the certificate for"
  type        = string
}

variable "zone_id" {
  description = "Route 53 Zone ID where to validate the certificate"
  type        = string
}
