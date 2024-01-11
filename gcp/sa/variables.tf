variable "name" {
  description = "Name of the service account"
  type        = string
}

variable "account_id" {
  description = "The ID of the GCP account that creates the service account"
}

variable "gcp_project_id" {
  description = "The id of the project to create the service account for"
  type        = string
}

variable "roles" {
  description = "The roles to assign to the service account"
  type        = string
}
