variable "name" {
  description = "Name of the key"
  type        = string
}

variable "project" {
  description = "Project where to create the keyring if needded"
  type        = string
}

variable "region" {
  description = "Where to create the keyring"
  type        = string
}

variable "create_key_ring" {
  description = "Wether to create a Key Ring to host the key or not"
  type        = bool
  default     = true
}

variable "key_ring" {
  description = "Key ring name for using existent one"
  type        = string
  default     = ""
}
