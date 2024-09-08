variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    description                  = optional(string, "")
    ip_protocol                  = string
    from_port                    = number
    to_port                      = number
    cidr_ipv4                    = optional(string, "")
    cidr_ipv6                    = optional(string, "")
    referenced_security_group_id = optional(string, "")
    tags                         = optional(map(string), {})
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules for the security group"
  type = list(object({
    description                  = optional(string, "")
    ip_protocol                  = string
    from_port                    = number
    to_port                      = number
    cidr_ipv4                    = optional(string, "")
    cidr_ipv6                    = optional(string, "")
    referenced_security_group_id = optional(string, "")
    tags                         = optional(map(string), {})
  }))
  default = []
}
