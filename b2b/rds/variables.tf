variable "name" {
  description = "The name for the RDS resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnets" {
  description = "The IDs of the subnets to associate with the RDS"
  type        = list(string)
}

variable "subnets_cidr" {
  description = "The CIDR subnet blocks of the security group"
  type        = list(string)
}

variable "postgres_admin_username" {
  description = "Postgres administrator username"
  type        = string
}

variable "postgres_admin_password" {
  description = "Postgres administrator password"
  type        = string
}

variable "skip_final_snapshot" {
  description = "Boolean value to determine whether a final DB snapshot is created before the DB instance is deleted"
  type        = bool
}

variable "multi_az" {
  description = "Boolean to specify if the RDS instance is multi-AZ"
  type        = bool
}

variable "instance" {
  description = "The class of the RDS instance"
  type        = string
  default     = "db.t4g.micro"
}

variable "postgres_version" {
  description = "The version of the postgres engine"
  type        = string
  default     = "14.4"
}

variable "allocated_storage" {
  description = "Specifies the value of the allocated storage for the RDS"
  type        = number
  default     = 5
}

variable "max_allocated_storage" {
  description = "Specifies the value of the max allocated storage for the RDS"
  type        = number
  default     = 10
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 0
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}
