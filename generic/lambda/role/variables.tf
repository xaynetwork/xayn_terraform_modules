variable "path" {
  description = "Path to the role"
  type        = string
  default     = null
}

variable "prefix" {
  description = "Prefix for the role name"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
