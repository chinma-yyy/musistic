variable "project" {
  description = "Name of the project"
  type        = string
  default     = "Rewind"
}

variable "subnet_id" {
  description = "Subnet ID for the nat to be deployed in"
  type        = string
}

