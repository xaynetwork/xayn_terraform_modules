variable "create_payload" {
  description = "The payload that is sent to the lambda function during creation"
  type        = map(string)

}

variable "delete_payload" {
  description = "The payload that is sent to the lambda function during deletion"
  type        = map(string)
}

variable "function_arn" {
  description = "The ARN of the lambda function that is invoked with the create and delete json payload"
  type        = string
}

variable "skip_delete" {
  description = "Set this to true to prevent the deletion of the real resource. It must be deleted manually. Can be overridden in the CLI."
  type        = bool
  default     = true
}
