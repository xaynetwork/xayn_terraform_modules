variable "description" {
  description = "Description of the role"
  type        = string
}

# optional parameters
variable "path" {
  description = "Path of the role"
  type        = string
  default     = "/"
}

variable "prefix" {
  description = "Prefix of the role name"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
