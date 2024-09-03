variable "vpc_id" {
  description = "The VPC ID to associate with the subnet"
  type        = string
}

variable "project" {
  description = "Project of the subnets to be deployed for"
  default = "Rewind"
  type = string
}
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "cidr_blocks" {
  description = "List of CIDR blocks for the subnets"
  type        = list(string)
}

variable "type" {
  description = "Type of subnet (public or private)"
  type        = string
}

variable "subnetCount" {
  description = "Number of subnets to create"
  type        = number
}