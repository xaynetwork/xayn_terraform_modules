variable "name" {
  description = "The name for the VPC endpoint resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnets_ids" {
  description = "The IDs of the subnets in which the endpoints are to be deployed"
  type        = list(string)
}

variable "subnets_cidr_blocks" {
  description = "The CIDR blocks of the subnets in which the endpoints are to be deployed"
  type        = list(string)
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
