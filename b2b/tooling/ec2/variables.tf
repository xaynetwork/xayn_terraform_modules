variable "iam_profile_name" {
  description = "Name of the IAM profile to launch the instance with"
  type        = string
}

variable "name" {
  description = "Name prefix of the ECS instances"
  type        = string
}

variable "subnet_id" {
  description = "VPC Subnet ID to launch in"
  type        = string
}

# optional parameters
variable "quantity" {
  description = "Number of instance to create"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "Instance type to use for the instance"
  type        = string
  default     = "t2.micro"
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to associate with"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
