variable "create_payload" {
  description = "The payload that is sent to the lambda function during creation"
  # can not use map(any) because all values witll be converted to the same type, in this case string
  type = any
}

variable "delete_payload" {
  description = "The payload that is sent to the lambda function during deletion"
  # can not use map(any) because all values witll be converted to the same type, in this case string
  type = any
}


variable "function_arn" {
  description = "The ARN of the lambda function that is invoked with the create and delete json payload"
  type        = string
}

variable "aws_profile" {
  description = "The AWS profile in which this function is executed"
  type        = string
}
