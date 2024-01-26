resource "google_project_service_identity" "gcp_service_identity" {
  provider = google-beta
  count    = length(var.gcp_service_identity)
  project  = var.project_id
  service  = var.gcp_service_identity[count.index]
}

# The executing service account that grants this role must itself hold the kms cloudkms.cryptoKeys.getIamPolicy permission
# on the key level.
# This can be granted via the `cloud kms Admin` role on the key level.
resource "google_kms_crypto_key_iam_member" "crypto_key" {
  for_each      = toset(var.grant_access_to_kms_crypro_keys)
  crypto_key_id = each.value
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.gcp_service_identity[count.index].email}"
}
