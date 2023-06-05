variable "service_name" {
  description = "Name of the app runner service"
  type        = string
}

variable "create_domain_association" {
  type        = bool
  description = "Whether to create a domain association for app runner."
  default     = false
}

variable "configure_deployment" {
  type        = bool
  description = "Whether to update the image whenever there are updates on the repos."
  default     = false
}

## Domain details
variable "domain_name" {
  type        = string
  description = "Name of the domein to add the app runner record."
}

variable "subdomain_name" {
  type        = string
  description = "Subdomain name for the app runner record."
}

## Container info
variable "container_port" {
  type        = number
  description = "Port number to display from the container."
}

variable "container_image" {
  type        = string
  description = "Name of the container."
}

variable "access_role" {
  type        = string
  description = "ARN of the access role with trust relationship to app runner."
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
