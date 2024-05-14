terraform {
  required_version = "v1.3.7"
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "2.18.0"
    }
  }
}

provider "grafana" {
  url = var.grafana_url
}
