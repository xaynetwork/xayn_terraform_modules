resource "google_kms_key_ring" "this" {
  name     = "${var.name}-ring"
  location = var.region
  project  = var.project
}

resource "google_kms_crypto_key" "this" {
  name                       = var.name
  key_ring                   = var.create_key_ring ? google_kms_key_ring.this.id : var.key_ring
  rotation_period            = "100000s"
  destroy_scheduled_duration = 240

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [null_resource.this]
}

resource "null_resource" "this" {
  count = var.create_key_ring ? 1 : 0

  depends_on = [google_kms_key_ring.this]

}
