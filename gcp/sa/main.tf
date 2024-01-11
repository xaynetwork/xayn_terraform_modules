resource "google_service_account" "this" {
  account_id   = var.account_id
  display_name = var.name
  project      = var.gcp_project_id
}

resource "google_project_iam_binding" "role_bindings" {
  count   = length(var.roles)
  project = var.gcp_project_id
  role    = var.roles[count.index]

  members = [
    "serviceAccount:${google_service_account.example_service_account.email}",
  ]
}
