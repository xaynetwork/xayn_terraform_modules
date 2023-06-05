variable "repositories" {
  description = "List of GitHub repositories to implement the role"
  type        = list(string)
}

variable "ecr_arns" {
  description = "A List of ARNs of the ECRs repository that the GH Role can access"
  type        = list(string)
}

variable "role_name" {
  description = "The name of the role"
  type        = string
  default     = "ecr-github-actions-role"
}

variable "policy_name"{
  description = "Name of the policy for ECR"
  type = string
  default = "ecr_gh_iam_policy"
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
