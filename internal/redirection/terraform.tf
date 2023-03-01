terraform {
  required_version = "1.3.7"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "4.40.0"
      configuration_aliases = [aws.us-east-1]
    }
  }
}
