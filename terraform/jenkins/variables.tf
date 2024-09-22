variable "region" {
  type        = string
  description = "Region for the aws"
  default     = "us-east-1"
}

variable "s3_bucket" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "s3_key" {
  description = "The path to the state file inside the S3 bucket"
  type        = string
}

variable "s3_region" {
  description = "The AWS region where the S3 bucket is located"
  type        = string
}

variable "s3_dynamodb_table" {
  description = "The name of the DynamoDB table for state locking"
  type        = string
}

variable "s3_dynamodb_endpoint" {
  description = "The custom endpoint for DynamoDB if any"
  type        = string
}

