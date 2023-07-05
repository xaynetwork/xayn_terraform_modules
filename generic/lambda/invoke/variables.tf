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

variable "aws_profile" {
  description = "The AWS profile in which this function is executed"
  type        = string
}
