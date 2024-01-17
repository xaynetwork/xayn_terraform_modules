resource "google_service_account" "cluster" {
  account_id   = var.name
  display_name = "Service Account used by GKE cluster: '${var.name}'."
}

resource "google_project_iam_member" "cluster_log_writer" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cluster.email}"
}

resource "google_project_iam_member" "cluster_metric_writer" {
  project = var.project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.cluster.email}"
}

resource "google_project_iam_member" "cluster_monitoring_viewer" {
  project = var.project
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.cluster.email}"
}

resource "google_project_iam_member" "cluster_metadata_writer" {
  project = var.project
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = "serviceAccount:${google_service_account.cluster.email}"
}

resource "google_project_iam_member" "cluster_sql_admin" {
  project = var.project
  role    = "roles/cloudsql.admin"
  member  = "serviceAccount:${google_service_account.cluster.email}"
}

#tfsec:ignore:google-gke-enable-network-policy We keep things simple for this demo
#tfsec:ignore:google-gke-enable-master-networks We keep things simple for this demo
#tfsec:ignore:google-gke-use-service-account False positive, we have a ServiceAccount setup
#tfsec:ignore:google-gke-metadata-endpoints-disabled False positive, ...
#tfsec:ignore:google-gke-enforce-pod-security-policy No PSPs, but no privileged pods allowed either...
resource "google_container_cluster" "cluster" {

  provider = google-beta

  name     = var.name
  location = var.region

  network             = var.network_id
  subnetwork          = var.subnetwork_id
  datapath_provider   = "ADVANCED_DATAPATH" # We use Dataplane V2
  enable_autopilot    = true
  deletion_protection = true

  resource_labels = {
    "managed-by" = "tf"
  }

  release_channel {
    channel = var.release_channel
  }

  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = google_service_account.cluster.email
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform",
        "https://www.googleapis.com/auth/monitoring" # required for Managed Prometheus
      ]
    }
  }

  node_pool_auto_config {
    network_tags {
      tags = [var.name]
    }
  }

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    master_global_access_config {
      enabled = true
    }
  }

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}


resource "google_compute_firewall" "cluster_admission_controller_access" {
  project     = var.project
  name        = "allow-gke-cp-access-admission-controller"
  network     = var.network_id
  description = "Allow ingress on tcp from GKE Control-Plane"

  allow {
    protocol = "tcp"
  }

  source_ranges = [google_container_cluster.cluster.private_cluster_config[0].master_ipv4_cidr_block]
  target_tags   = [var.name]
}


