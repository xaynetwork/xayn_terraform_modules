variable "name" {
  description = "Name of the Cloudformation stack."
  type        = string
}

variable "template_url" {
  description = "Location of a file containing the template body."
  type        = string
}

variable "s3_bucket" {
  description = "Name of the existing S3 bucket to hold athena result data."
  type        = string
}
