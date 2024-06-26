variable "name" {
  type        = string
  description = "The name of the distributed cache system"
}

variable "spec_code" {
  type        = string
  description = "The type of redis server that is going to be deployed"
  default     = "redis.single.xu1.tiny.128"
}

variable "engine_version" {
  type        = string
  description = "The version of the redis engine"
  default     = "5.0"
}

variable "capacity" {
  type        = number
  description = "The type instance values for stand-alone or cluster"
  default     = 0.125
}

variable "region_zone" {
  type        = string
  description = "The region zone identifier: i.e. eu-de-01"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where to deploy the server"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet where to deploy the server"
}

variable "dcs_password" {
  type        = string
  description = "DCS password value"
}
