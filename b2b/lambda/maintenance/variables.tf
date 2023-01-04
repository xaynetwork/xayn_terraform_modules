variable "subnet_ids" {
  description = "VPC subnet IDs to launch the lambda function in"
  type        = list(string)
}

variable "vpc_id" {
  description = "The vpc id that the lambda function should belong to."
  type        = string
}

variable "subnets_cidr_blocks" {
  description = "The CIDR blocks of the subnets of the lambda egress security group"
  type        = list(string)
}

# optional parameters
variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events of all lambdas"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
