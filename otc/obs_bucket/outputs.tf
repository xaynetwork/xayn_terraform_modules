output "bucket_domain_name" {
  value = opentelekomcloud_obs_bucket.models.bucket_domain_name
}

output "bucket_access_key" {
  value     = opentelekomcloud_identity_credential_v3.user_aksk.access
  sensitive = true
}

output "bucket_secret_key" {
  value     = opentelekomcloud_identity_credential_v3.user_aksk.secret
  sensitive = true
}
