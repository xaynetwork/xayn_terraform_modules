variable "repo_names" {
  description = "A list of ECR repositories to be created"
  type        = list(string)
}

variable "read_access_account_ids" {
  type        = list(string)
  description = "A list of account ids that can read access this ecr repo."
  default     = []
}

variable "repository_type" {
  type = string
  description = "The type of the repository to be created."
  default = "private"
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
