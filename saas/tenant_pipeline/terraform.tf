terraform {
  required_version = "1.3.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.67.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.2.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}
