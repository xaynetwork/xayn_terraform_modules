variable "service_name" {
  description = "Service to which is needed to associate the key"
  type        = list(string)
}

variable "key_id" {
  description = "The ID of the key to associate with the service account"
  type        = string
}
