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

# Service configuration
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

variable "private_registry_access" {
  description = "Describes a request to configure an Amazon Lightsail container service to access private container image repositories"
  type        = bool
  default     = false
}

## Container data
variable "containers" {
  description = "Configuration for the containers to deploy"
  type = list(object({
    name    = string
    image   = string
    port    = map(string)
    command = list(string)
    envs    = map(string)
  }))
}

variable "public_container" {
  description = " The name of the main container to access"
  type        = string
}

variable "public_port" {
  description = "The number of the port to access the public container."
  type        = string
}

variable "health_check_path" {
  description = "The path to check the container health."
  type        = string
  default     = "/"
}

variable "health_success_codes" {
  description = "The success code for the health of the container."
  type        = string
  default     = "200-499"
}
