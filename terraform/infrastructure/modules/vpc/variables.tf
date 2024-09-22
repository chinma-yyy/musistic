variable "project" {
  description = "Name of the project"
  default     = "Rewind"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
  type        = string
}
