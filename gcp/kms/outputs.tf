output "key_id" {
  description = "KMS identifier"
  value       = google_kms_crypto_key.this.id
}
