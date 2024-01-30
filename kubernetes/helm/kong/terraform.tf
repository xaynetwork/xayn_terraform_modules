terraform {
  required_version = "1.3.7"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.25.2"
    }
  }
}
