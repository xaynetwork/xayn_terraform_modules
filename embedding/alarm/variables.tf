variable "alarm_arns" {
  description = "List of all alarm ARNs that are part of the composite alarm."
  type        = list(string)
  default     = []
}

variable "create_alarm" {
  description = "Whether to create the alarm."
  type        = bool
  default     = true
}

variable "alarm_actions" {
  description = "The set of actions to execute when this alarm transitions to the ALARM state from any other state."
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = " The set of actions to execute when this alarm transitions to an OK state from any other state."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of labels to apply to contained resources."
  type        = map(string)
  default     = {}
}
