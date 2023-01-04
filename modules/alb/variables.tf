variable "name" {
  description = "The name for the ALB resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnets" {
  description = "The IDs of the subnets to associate with the ALB"
  type        = list(string)
}

variable "subnets_cidr_blocks" {
  description = "The CIDR subnet blocks of the security group"
  type        = list(string)
}

variable "listener_port" {
  description = "Value of the port for the listener"
  type        = number
}

variable "listener_default_response" {
  description = "Default response if no rule matches"
  type = object({
    content_type = string
    message_body = string
    status_code  = string
  })
  default = {
    content_type = "text/plain"
    message_body = "Not Found"
    status_code  = "404"
  }
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
