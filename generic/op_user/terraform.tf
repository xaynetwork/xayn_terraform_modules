terraform {
  required_version = "v1.3.7"
  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "1.4.1"
    }
  }
}

provider "onepassword" {
  account = var.op_account
}
