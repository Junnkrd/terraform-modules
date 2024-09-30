terraform {
  required_version = "1.9.6"
  required_providers {
    aws   = ">=5.69.0"
    local = ">=2.1.0"
  }

  backend "s3" {
    bucket = "junnkrd-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}
