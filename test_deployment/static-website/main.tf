terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module s3-website-creation {
  source = "../../modules/s3-static-website/v1.0.0"
  region = var.region
  static-website-name = var.static-website-name
}