variable "name" {
  description = "The name for the VPC cluster"
  type        = string
}

variable "cidr_block" {
  description = "The value of the cidr block for the VPC of the cluster"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets for the deployment"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnets for the deployment"
  type        = list(string)
}

variable "enable_dns" {
  description = "Enable the DNS hostnames in the VPC"
  type        = bool
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
