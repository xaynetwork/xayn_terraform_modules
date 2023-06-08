data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_lightsail_database" "this" {
  relational_database_name = var.db_name
  availability_zone    = data.aws_availability_zones.available_zones.names[0]
  master_database_name = var.db_name
  master_password      = var.db_password
  master_username      = var.db_username
  blueprint_id         = var.db_blueprint
  bundle_id            = var.db_bundle_id
}
