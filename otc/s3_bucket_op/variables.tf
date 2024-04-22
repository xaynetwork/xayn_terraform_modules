variable "bucket_name" {
  type        = string
  description = "Project name or context"
}

variable "secret_key_uid" {
  type        = string
  description = "ID of the item for the Secret Key"
}

variable "region" {
  type        = string
  description = "OTC region for the project: eu-nl(default) or eu-de"
  default     = "eu-nl"
  validation {
    condition     = contains(["eu-de", "eu-nl"], var.region)
    error_message = "Allowed values for region are \"eu-de\" and \"eu-nl\"."
  }
}
