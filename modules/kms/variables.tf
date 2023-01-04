variable "name" {
  description = "Name of the key"
  type        = string
}

# optional parameters
variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
