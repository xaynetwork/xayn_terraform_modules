variable "name" {
  type        = string
  description = "The name of the key"
}

variable "description" {
  type        = string
  description = "The description of the key"
}


variable "region_zone" {
  type        = string
  description = "The region zone identifier: i.e. eu-de-01"
}

variable "pending_days" {
  type        = number
  default     = 30
  description = "(Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 1096 days. Defaults to 30. It only is used when delete a key."
}
