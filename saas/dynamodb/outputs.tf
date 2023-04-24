output "db_name" {
  description = "The table name."
  value = local.db_name
}

output "db_arn" {
  description = "The ARN of the table."
  value = module.dynamodb_table.dynamodb_table_arn
}
