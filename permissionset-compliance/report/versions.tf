terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.26"
    }
  }
  backend "s3" {
    key = "permissionset-compliance/report/terraform.tfstate"
  }
}