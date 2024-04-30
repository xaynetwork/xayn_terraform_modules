variable "bucket_name" {
  type        = string
  description = "Project name or context"
}

locals {
  bucket_name = replace(lower(var.bucket_name), "_", "-")
}
