terraform {
  required_version = ">= 1.9.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = var.s3_bucket
    key            = var.s3_key
    region         = var.region
    dynamodb_table = var.s3_dynamodb_table
    endpoints = {
      dynamodb = "${var.s3_dynamodb_endpoint}"
    }
  }

}

provider "aws" {
  region = var.region
}




