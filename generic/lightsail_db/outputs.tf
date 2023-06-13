output "db_address" {
  value = aws_lightsail_database.this.master_endpoint_address
}
