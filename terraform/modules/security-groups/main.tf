resource "aws_security_group" "security_group" {
  name   = var.name
  vpc_id = var.vpc_id

  tags = {
    Name = var.name
  }
}

# Create ingress rules
resource "aws_vpc_security_group_ingress_rule" "ingress_rules" {
  count             = length(var.ingress_rules)
  security_group_id = aws_security_group.security_group.id
  description       = var.ingress_rules[count.index].description
  ip_protocol       = var.ingress_rules[count.index].ip_protocol
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  # Ensure only one of the following attributes is configured
  cidr_ipv4                    = var.ingress_rules[count.index].cidr_ipv4 != "" ? var.ingress_rules[count.index].cidr_ipv4 : null
  cidr_ipv6                    = var.ingress_rules[count.index].cidr_ipv6 != "" ? var.ingress_rules[count.index].cidr_ipv6 : null
  referenced_security_group_id = var.ingress_rules[count.index].referenced_security_group_id != "" ? var.ingress_rules[count.index].referenced_security_group_id : null
  tags                         = var.ingress_rules[count.index].tags
}

# Create egress rules
resource "aws_vpc_security_group_egress_rule" "egress_rules" {
  count             = length(var.egress_rules)
  security_group_id = aws_security_group.security_group.id
  description       = var.egress_rules[count.index].description
  ip_protocol       = var.egress_rules[count.index].ip_protocol
  from_port         = var.egress_rules[count.index].from_port
  to_port           = var.egress_rules[count.index].to_port
  # Ensure only one of the following attributes is configured
  cidr_ipv4                    = var.egress_rules[count.index].cidr_ipv4 != "" ? var.egress_rules[count.index].cidr_ipv4 : null
  cidr_ipv6                    = var.egress_rules[count.index].cidr_ipv6 != "" ? var.egress_rules[count.index].cidr_ipv6 : null
  referenced_security_group_id = var.egress_rules[count.index].referenced_security_group_id != "" ? var.egress_rules[count.index].referenced_security_group_id : null
  tags                         = var.egress_rules[count.index].tags
}
