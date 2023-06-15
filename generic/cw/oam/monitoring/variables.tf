variable "sink_name" {
  description = "Name for the sink."
  type        = string
}

variable "source_accounts" {
  description = "Accounts that are sharing data with this monitoring account."
  type        = list(string)
  default     = []
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
