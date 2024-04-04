terraform {
  required_version = "v1.3.7"
  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">=1.29.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "1.4.1"
    }
  }
}
