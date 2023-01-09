variable "name" {
  description = "Name of the bastion resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "VPC subnet ID to launch in the bastion hosts"
  type        = string
}

variable "egress_cidr_blocks" {
  description = "The egress CIDR blocks of the bastion security group"
  type        = list(string)
}

# optional parameters
variable "quantity" {
  description = "Instance type to use for the instance"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
