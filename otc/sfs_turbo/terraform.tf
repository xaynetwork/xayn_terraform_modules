terraform {
  required_version = "v1.3.7"
  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = "1.36.5"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.6.0"
    }
  }
}
