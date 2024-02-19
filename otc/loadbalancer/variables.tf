variable "name" {
  type        = string
  description = "Project name."
}

variable "bandwidth" {
  type        = number
  default     = 300
  description = "The bandwidth size. The value ranges from 1 to 1000 Mbit/s."
}

variable "vpc_id" {
  type        = string
  description = "VPC where the elastic load balancer will be created."
}

variable "subnet_id" {
  type        = string
  description = "Subnets where the elastic load balancer will be created."
}

variable "availability_zones" {
  type        = list(string)
  description = "Specifies the availability zones where the LoadBalancer will be located."
}

variable "l4_flavor" {
  type        = string
  description = "The flavor for the L4 ELB, if not assigned and L7 also not assigned then both will be created with default values"
  default     = null
}

variable "l7_flavor" {
  type        = string
  description = "The flavor for the L7 ELB, if not assigned and L4 also not assigned then both will be created with default values"
  default     = null
}
