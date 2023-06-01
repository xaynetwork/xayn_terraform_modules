output "db_name" {
  description = "The table name."
  value       = local.db_name
}

output "db_arn" {
  description = "The ARN of the table."
  value       = module.dynamodb_table.dynamodb_table_arn
}

output "stream_arn" {
  description = "The arn that a consumer can attach it self to listen for changes"
  value       = module.dynamodb_table.dynamodb_table_stream_arn
}
