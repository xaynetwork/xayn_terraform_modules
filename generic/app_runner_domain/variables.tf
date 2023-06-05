variable "domain_name" {
  type        = string
  description = "Name of the domein to add the app runner record."
}

variable "subdomain_name" {
  type        = string
  description = "Subdomain name for the app runner record."
}

variable "custom_domain_association_certificate_validation_records" {
  type        = any
  description = "A set of certificate CNAME records used for this domain name."
}

variable "service_url" {
  type        = string
  description = "AWS url for the App Runner."
}
