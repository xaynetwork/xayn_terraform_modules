resource "google_service_account" "this" {
  account_id   = var.account_id
  display_name = "${var.name}-sa"
  project      = var.project_id
}

resource "google_project_iam_binding" "role_bindings" {
  count   = length(var.roles)
  project = var.project_id
  role    = var.roles[count.index]

  members = [
    "serviceAccount:${google_service_account.this.email}",
  ]
}

# The executing service account that grants this role must itself hold the kms cloudkms.cryptoKeys.getIamPolicy permission
# on the key level.
# This can be granted via the `cloud kms Admin` role on the key level.
resource "google_kms_crypto_key_iam_member" "crypto_key" {
  for_each      = toset(var.grant_access_to_kms_crypro_keys)
  crypto_key_id = each.value
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.this.email}"
}
