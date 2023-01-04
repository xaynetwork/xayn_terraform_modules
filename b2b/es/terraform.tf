terraform {
  required_version = "1.3.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.37.0"
    }
    ec = {
      source  = "elastic/ec"
      version = "0.5.0"
    }
  }
}
