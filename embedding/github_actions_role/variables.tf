variable "repositories" {
  description = "List of GitHub repositories to implement the role"
  type        = list(string)
}

variable "ecr_arn" {
  description = "The ARN of the ECR repository that the GH Role can access"
  type        = string
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
