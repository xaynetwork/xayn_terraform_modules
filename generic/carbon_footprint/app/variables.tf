variable "principals" {
  description = "List of principals that are allowed to assume the app role."
  type        = list(string)
}

variable "billing_data_bucket" {
  description = "Name of the existing S3 bucket to hold generated reports."
  type        = string
}

variable "athena_query_results_bucket" {
  description = "Name of the existing S3 bucket to hold athena result data."
  type        = string
}
