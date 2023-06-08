variable "service_url" {
  description = " The default domain created for the container."
  type        = string
}

variable "domain_name" {
  description = " The name of the domain region where to create the record."
  type        = string
}

variable "subdomain_name" {
  description = " The name of the domain for the container."
  type        = string
}

variable "certificate_validation_records" {
  type = any
  description = "Records to validate the certificates"
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
