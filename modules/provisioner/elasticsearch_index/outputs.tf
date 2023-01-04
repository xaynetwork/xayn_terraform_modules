output "result" {
  description = "Result of the invoke call"
  value       = "${module.elasticsearch_index.status_code}: ${module.elasticsearch_index.body}"
}
