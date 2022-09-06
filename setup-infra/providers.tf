# Documentation: https://www.terraform.io/docs/language/settings/index.html
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "chalice-tf-state-bucket"
    key    = "remote-data"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}