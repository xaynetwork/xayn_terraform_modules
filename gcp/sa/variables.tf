variable "name" {
  description = "The displayed name of the project"
  type        = string
}

variable "account_id" {
  description = "The ID of the account for the service account"
  type        = string
}

variable "roles" {
  description = "The roles to assign to the service account"
  type        = list(string)
}

variable "project_id" {
  description = "The ID of the project to be created"
  type        = string
  default     = ""
}
