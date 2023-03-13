variable "name" {
  description = "The name for the composite alarm. This name must be unique within the region."
  type        = string
}

variable "description" {
  description = "The description for the composite alarm."
  type        = string
}

variable "rule" {
  description = "An expression that specifies which other alarms are to be evaluated to determine this composite alarm's state."
  type        = string
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
