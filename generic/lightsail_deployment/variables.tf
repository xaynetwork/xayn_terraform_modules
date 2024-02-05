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

variable "health_check" {
  description = "The health check configuration for the container"
  type = object({
    healthy_threshold   = optional(number, 2)
    unhealthy_threshold = optional(number, 2)
    timeout_sec         = optional(number, 2)
    interval_sec        = optional(number, 5)
    path                = string
    success_code        = optional(string, "200-499")
  })
  default = {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout_sec         = 2
    interval_sec        = 5
    path                = "/"
    success_code        = "200-499"
  }
}
