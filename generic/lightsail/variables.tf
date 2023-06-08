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

variable "repository_name" {
  type        = string
  description = "Name of the private ECR repo to download images."
}

## Container information

variable "container_image" {
  description = " The name of the container image."
  type        = string
}

variable "ports" {
  description = "The number of the port to access the container."
  type        = map(string)
}

# Domain settings
variable "certificate_name" {
  description = "Name of the validated certificate for SSL"
  type        = string
}

variable "domain_name" {
  description = "The name of the DNS region."
  type        = string
}

variable "subdomain_name" {
  description = "The domain name for the app."
  type        = string
}
