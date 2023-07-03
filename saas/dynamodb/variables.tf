variable "enable_pit" {
  description = "Whether to enable point-in-time recovery"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
