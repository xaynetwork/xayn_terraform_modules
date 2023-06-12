variable "db_name" {
  description = "Name for an automatically created database on creation"
  type        = string
}

variable "db_password" {
  description = "Password for the master DB user"
  type        = string
}

variable "db_username" {
  description = "Username for the master DB user"
  type        = string
}

variable "db_blueprint" {
  description = "A blueprint describes the major engine version of a database."
  type        = string
  default     = "postgres_15"
}

variable "db_bundle_id" {
  description = "Name for an automatically created database on creation"
  type        = string
  default     = "micro_2_0"
}

variable "subdomain_name" {
  description = " The name of the domain for the container."
  type        = string
}
