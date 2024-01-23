variable "project_name" {
  description = "The displayed name of the project"
  type        = string
}

variable "project_id" {
  description = "The ID of the project to be created"
  type        = string
}

variable "folder_id" {
  description = "The numeric ID of the folder where this project is going to be created"
  type        = number
}

variable "billing_account_id" {
  description = "The id of the billing account that should be accossiateed with that project"
  type        = string
}

variable "gcp_service_list" {
  description = "The list of apis necessary for the project"
  type        = list(string)
}
