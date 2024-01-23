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
