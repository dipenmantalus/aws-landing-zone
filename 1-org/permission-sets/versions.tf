terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.26"
    }
  }
  backend "s3" {
    key = "1-org/permission-set/terraform.tfstate"
  }
}