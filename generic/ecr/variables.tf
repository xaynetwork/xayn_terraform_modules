variable "name" {
  description = "The name of the ECR repository"
  type        = string
}

variable "read_access_account_ids" {
  type        = list(string)
  description = "A list of account ids that can read access this ecr repo."
  default     = []
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
