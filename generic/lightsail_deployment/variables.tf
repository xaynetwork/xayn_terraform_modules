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
  type = list(object({
    healthy_threshold   = number
    unhealthy_threshold = number
    timeout_sec         = number
    interval_sec        = number
    path                = string
    success_code        = string
  }))
  default = [{
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout_sec         = 2
    interval_sec        = 5
    path                = "/"
    success_code        = "200-499"
  }]
}
