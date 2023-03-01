variable "function_name" {
  description = "A unique name for your lambda function"
  type        = string
}

variable "handler" {
  description = "Lambda function entrypoint in your code"
  type        = string
}

variable "runtime" {
  description = "Lambda function runtime"
  type        = string
}

variable "architecture" {
  description = "Lambda function architecture"
  type        = string
  default     = "arm64"
}

variable "source_code_path" {
  description = "The path of the source code, this is used to create the source code hash"
  type        = string
}

variable "output_path" {
  description = "Output path of the archive"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN of the lambda role"
  type        = string
}

# optional parameters
variable "vpc_subnet_ids" {
  description = "List of subnet IDs when Lambda Function should run in the VPC. Usually private or intra subnets."
  type        = list(string)
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs when Lambda Function should run in the VPC."
  type        = list(string)
  default     = null
}

variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events of all lambdas"
  type        = number
  default     = 7
}

variable "timeout" {
  description = "Amount of time your Lambda Function has to run in seconds"
  type        = number
  default     = 3
}

variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
