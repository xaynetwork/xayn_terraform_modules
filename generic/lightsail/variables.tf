variable "service_name" {
  description = " The name for the container service."
  type        = string
}

variable "power" {
  description = "The power specifies the amount of memory, the number of vCPUs, and the monthly price of each node of the container service."
  type        = string
  default     = "nano"
}

variable "node_number" {
  description = "The allocated compute nodes of the container service."
  type        = number
  default     = 1
}

## ECR
variable "private_registry_access" {
  description = "Describes a request to configure an Amazon Lightsail container service to access private container image repositories"
  type        = bool
  default     = false
}

# Domain settings
variable "certificate_name" {
  description = "Name of the validated certificate for SSL"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "The name of the DNS region."
  type        = string
  default     = ""
}

variable "subdomain_name" {
  description = "The domain name for the app."
  type        = string
  default     = ""
}
