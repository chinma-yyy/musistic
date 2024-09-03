# Allocate Elastic IPs for NAT Gateways
resource "aws_eip" "nat_eip" {
  tags = {
    Name = "${var.project}"
  }
}

# Create NAT Gateways
resource "aws_nat_gateway" "nat_gateway" {
  subnet_id     = var.subnet_id
  allocation_id = aws_eip.nat_eip.id

  tags = {
    Name = "${var.project}-nat-gateway"
  }
}
