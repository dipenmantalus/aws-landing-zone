terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.26"
    }
    # Add this block to fix the 'hashicorp/awsutils' error
    awsutils = {
      source  = "cloudposse/awsutils"
      version = ">= 0.1.0"
    }
  }

  backend "s3" {
    # Ensure this key remains present
    key = "0-bootstrap/lz-ci-cd-bootstrap/terraform.tfstate"
  }
}