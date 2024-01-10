variable "service_name" {
  description = " The name for the container service."
  type        = string
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
