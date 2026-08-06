terraform {
  backend "s3" {
    bucket       = "piksel-production-iac-state"
    key          = "production/terraform.tfstate"
    region       = "ap-southeast-3"
    use_lockfile = true
    encrypt      = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, < 7.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
