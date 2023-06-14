variable "sink_identifier" {
  description = "Identifier of the sink to use to create this link."
  type        = string
}

variable "label_template" {
  description = "Human-readable name to use to identify this source account when you are viewing data from it in the monitoring account."
  type        = string
  default     = "$AccountName"
}

variable "resource_types" {
  description = "Types of data that the source account shares with the monitoring account."
  type        = list(string)
  default     = ["AWS::CloudWatch::Metric", "AWS::Logs::LogGroup", "AWS::XRay::Trace"]
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
