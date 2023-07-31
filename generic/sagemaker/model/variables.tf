variable "primary_container" {
  description = "The primary docker image containing inference code that is used when the model is deployed for predictions."
  type        = any
}

variable "enable_network_isolation" {
  description = "Isolates the model container. No inbound or outbound network calls can be made to or from the model container."
  type        = bool
  default     = false
}

variable "vpc_config" {
  description = "Specifies the VPC that you want your model to connect to. VpcConfig is used in hosting services and in batch transform."
  type        = any
  default     = {}
}

variable "role_name" {
  description = "Name of IAM role to use for Sagemaker"
  type        = string
}

variable "role_description" {
  description = "Description of IAM role to use for Sagemaker"
  type        = string
  default     = null
}

variable "policy_name" {
  description = "IAM policy name."
  type        = string
}

variable "policy_jsons" {
  description = "An additional policy documents as JSON to attach to the Sagemaker role"
  type        = list(any)
  default     = []
}

variable "model_buckets" {
  description = "List of S3 bucket names that Sagemaker should be given access to."
  type        = list(string)
  default     = []
}

variable "ecr_repositories" {
  description = "List of ECR repository arns that Sagemaker should be given access to."
  type        = list(string)
}

variable "create_security_group" {
  description = "Determines if a security group is created"
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Name to use on security group created"
  type        = string
  default     = null
}

variable "security_group_use_name_prefix" {
  description = "Determines whether the security group name (`security_group_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = null
}

variable "security_group_rules" {
  description = "Security group rules to add to the security group created"
  type        = any
  default     = {}
}

variable "tags" {
  description = "Custom tags to set on the underlining resources."
  type        = map(string)
  default     = {}
}
