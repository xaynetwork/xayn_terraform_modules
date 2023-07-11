variable "service_name" {
  description = " The name for the container service."
  type        = string
}

variable "private_registry_access" {
  description = "Describes a request to configure an Amazon Lightsail container service to access private container image repositories"
  type        = bool
  default     = false
}

variable "ecr_role" {
  description = " The name for the container service."
  type        = string
  default     = null
}

## Container data
variable "container_image" {
  description = " The name of the container image."
  type        = string
}

variable "ports" {
  description = "The number of the port to access the container."
  type        = map(string)
}

variable "environmental_variables" {
  description = "Pair of key-value environmental variables for the container."
  type        = map(string)
  default     = {}
}

variable "container_command" {
  description = "Launch commands for the container."
  type        = list(string)
  default     = []
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
