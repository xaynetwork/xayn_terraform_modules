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

variable "external_account" {
  description = "The name of the external SA to give access in this project"
  type        = string
  default     = ""
}

variable "external_roles" {
  description = "The roles to give in to the external SA"
  type        = list(string)
  default     = []
}

variable "grant_access_to_kms_crypro_keys" {
  description = "A list of keys that the Service account should receive Encryter / Descrpter role"
  type        = list(string)
  default     = []
}
