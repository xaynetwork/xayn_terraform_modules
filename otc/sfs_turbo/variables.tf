variable "volume_name" {
  type = string
}

variable "size" {
  default     = 500
  description = "Size of the SFS volume in GB. (Default: 500)"
  type        = number
}

variable "share_type" {
  default     = "STANDARD"
  description = "Filesystem type of the SFS volume. (Default: STANDARD)"
  type        = string
}

variable "availability_zone" {
  default = "eu-de-01"
  type    = string
}

variable "vpc_id" {
  description = "VPC id where the SFS volume will be created in."
  type        = string
}

variable "subnet_id" {
  type        = string
  description = "Subnet network id where the SFS volume will be created in."
}

variable "kms_key_id" {
  type        = string
  description = "Existing KMS Key ID if one is already created."
  default     = null
}

variable "kms_key_create" {
  type    = bool
  default = true
}
