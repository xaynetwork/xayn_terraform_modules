terraform {
  required_version = "1.3.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.50.0"
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
