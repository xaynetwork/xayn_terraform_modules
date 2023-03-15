variable "name" {
  description = "The name for the ECS cluster"
  type        = string
}

variable "container_insights" {
  description = "Whether container insights should be enabled"
  type        = bool
  default     = true
}

variable "capacity_provider_strategy" {
  description = "Describes a spot instance configuration. Weights are between 0..100 and base defines the always running instances. Only one base can be 0."
  type = object({
    fargate_weight      = number
    fargate_base        = number
    fargate_spot_weight = number
    fargate_spot_base   = number
  })
  default = null
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
