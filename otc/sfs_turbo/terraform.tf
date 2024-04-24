terraform {
  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = "1.36.6"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.6.0"
    }
  }
}
