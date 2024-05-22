terraform {
  required_version = "v1.3.7"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.30.0"
    }

    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = "1.36.7"
    }

    wireguard = {
      source  = "OJFord/wireguard"
      version = "0.2.2"
    }
  }
}
