terraform {
  required_version = "1.3.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.37.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.2.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.2.3"
    }
  }
}
