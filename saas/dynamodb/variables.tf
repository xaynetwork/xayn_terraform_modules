variable "retention_days" {
  description = "The number of days to keep the backups"
  type        = number
  default     = 7
}

variable "backup_frecuency" {
  description = "How often do we want to do the backup of the dynamodb table(in cron setup)"
  type        = string
  default     = "cron(0 12 * * ? *)"
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
