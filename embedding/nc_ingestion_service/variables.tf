variable "cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

## network
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "VPC subnet IDs to launch in the ECS service"
  type        = list(string)
}

## task
variable "container_image" {
  description = "Specifies value of the container image"
  type        = string
}

# optional parameters
variable "container_port" {
  description = "Port of the container"
  type        = number
  default     = 8000
}

variable "container_cpu" {
  description = "The number of cpu units the ECS container agent reserves for the container"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "The hard limit of memory (in MiB) to present to the task"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running"
  type        = number
  default     = 2
}

variable "max_count" {
  description = "Max number of scalable service tasks"
  type        = number
  default     = 4
}

variable "auth_json" {
  description = "The base64 encoded json that is necessary to authenticate with the Google APIs"
  type        = string
  sensitive   = true
}

variable "capacity_provider_strategy" {
  description = "Describes a spot instance configuration. Weights are between 0..100 and base defines the always running instances. Only one base can be 0."
  type = object({
    fargate_weight      = number
    fargate_base        = number
    fargate_spot_weight = number
    fargate_spot_base   = number
  })

  default = {
    fargate_base        = 1
    fargate_spot_base   = 0
    fargate_spot_weight = 100
    fargate_weight      = 0
  }
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
