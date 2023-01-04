variable "name" {
  description = "The name for the NLB resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "alb_id" {
  description = "The ID of the ALB"
  type        = string
}

variable "subnets" {
  description = "The IDs of the subnets to associated with the ALB"
  type        = list(string)
}

variable "listener_port" {
  description = "Value of the port for the listener"
  type        = number
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
