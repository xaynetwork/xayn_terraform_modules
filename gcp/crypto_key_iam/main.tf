resource "google_kms_crypto_key_iam_member" "crypto_key" {
  count         = length(var.service_name)
  crypto_key_id = var.key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@${var.service_name[count.index]}.iam.gserviceaccount.com"
}

data "google_project" "project" {
  project_id = var.project_id
}
