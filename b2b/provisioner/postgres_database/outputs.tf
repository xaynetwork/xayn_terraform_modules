output "result" {
  description = "Result of the invoke call"
  value       = "${module.postgres_database.status_code}: ${module.postgres_database.body}"
}
