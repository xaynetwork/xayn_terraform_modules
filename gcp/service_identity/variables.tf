variable "project_id" {
  description = "The ID of the project to be created"
  type        = string
}

variable "gcp_service_identity" {
  description = "The list of apis necessary for the project"
  type        = list(string)
  default     = []
}

variable "grant_access_to_kms_crypro_keys" {
  description = "A list of keys that the Service account should receive Encryter / Descrpter role"
  type        = list(string)
  default     = []
}
