variable "name" {
  type        = string
  description = "The name of the distributed cache system"
}

variable "password" {
  type        = string
  description = "The password for the database"
}

variable "type" {
  type        = string
  description = "The type of database to configure"
  default     = "PostgreSQL"
}

variable "db_version" {
  type        = string
  description = "The database version"
  default     = "9.5"
}

variable "port" {
  type        = string
  description = "The port for accessing the database"
  default     = "5432"
}

# To obtain follow https://docs.otc.t-systems.com/relational-database-service/api-ref/api_v3_recommended/querying_database_specifications.html#rds-06-0002-table1336414511696
variable "flavor" {
  type        = string
  description = "The flavor for the database server"
  default     = "rds.pg.c2.medium"
}

variable "volume" {
  type = object({
    type = string
    size = number
  })
  description = "The configuration of the volume of the database"
  default = {
    type = "ULTRAHIGH"
    size = 40
  }
}

variable "backup_strategy" {
  type = object({
    start_time = string
    keep_days  = number
  })
  description = "The configuration of the volume of the database"
  default     = null
}

variable "region_zone" {
  type        = string
  description = "The region zone identifier: i.e. eu-de-01"
}

##### NETWORKING

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet where to deploy the server"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the vpc where to deploy the server"
}

variable "remote_cidr" {
  type        = string
  description = "The value of the CIDR of the remote to access the db"
}
