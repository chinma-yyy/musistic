variable "region" {
  description = "Region for the resources"
  type = string
  default = "us-east-1"
}
variable "project" {
  description = "Name of the project"
  type = string
  default = "Rewind"
}

variable "cidr_block" {
  description = "CIDR block for the main vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cidr_block_public_1" {
  description = "CIDR block for public 1 subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "cidr_block_public_2" {
  description = "CIDR block for public 1 subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "cidr_block_private_1a" {
  description = "CIDR block for private 1a subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "cidr_block_private_1b" {
  description = "CIDR block for private 1b subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "cidr_block_private_2a" {
  description = "CIDR block for private 2a subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "cidr_block_private_2b" {
  description = "CIDR block for private 2b subnet"
  type        = string
  default     = "10.0.5.0/24"
}

