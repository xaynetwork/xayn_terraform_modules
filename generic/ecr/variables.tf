variable "name" {
  description = "The name of the ECR repository"
  type        = string
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
