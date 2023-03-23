variable "report_name" {
  description = "Unique name for the report. Must start with a number/letter and is case sensitive. Limited to 256 characters."
  type        = string
}

variable "s3_bucket" {
  description = "Name of the existing S3 bucket to hold generated reports."
  type        = string
}

variable "s3_prefix" {
  description = "Report path prefix. Limited to 256 characters."
  type        = string
  default     = "report"
}

variable "time_unit" {
  description = "The frequency on which report data are measured and displayed."
  type        = string
  default     = "HOURLY"

  validation {
    condition     = contains(["HOURLY", "DAILY", "MONTHLY"], var.time_unit)
    error_message = "Only HOURLY, DAILY or MONTHLY are allowed."
  }
}
