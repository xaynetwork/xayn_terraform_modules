terraform {
  required_version = "1.3.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.37.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}
