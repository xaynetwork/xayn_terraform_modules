variable "name" {
  description = "The name for the ECS cluster"
  type        = string
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
