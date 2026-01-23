terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.26" # Minimum version required for new data sources
    }
    awsutils = {
      source  = "cloudposse/awsutils"
      version = ">= 0.1.0"
    }
    external = {
      source = "hashicorp/external"
    }
  }
}