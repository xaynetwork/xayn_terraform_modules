output "id" {
  description = "Service Account identifier"
  value       = google_service_account.this.id
}

output "sa_email" {
  description = "The email from the created service account"
  value       = google_service_account.this.email
}
