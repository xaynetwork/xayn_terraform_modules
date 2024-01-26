resource "google_project" "this" {
  name            = var.project_name
  project_id      = var.project_id
  folder_id       = var.folder_id
  billing_account = var.billing_account_id
}

resource "google_project_service" "gcp_services" {
  for_each = toset(var.gcp_service_list)
  project  = google_project.this.id
  service  = each.key
}

resource "google_project_service_identity" "gcp_service_identity" {
  provider = google-beta
  count    = length(var.gcp_service_identity)
  project  = google_project.this.id
  service  = var.gcp_service_identity[count.index]
}
