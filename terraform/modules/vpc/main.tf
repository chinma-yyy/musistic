// Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.cidr_block
  
  tags = {
    Name = var.project
    Project = var.project
  }
}

// Create IGW
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name    = "${var.project}-IGW"
    Project = var.project
  }
}

// Create a route table which will be our main
resource "aws_route_table" "custom_main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.project}-main-RT"
    Project = var.project
  }
}

// Associate the
resource "aws_main_route_table_association" "main_route_table_association" {
  vpc_id         = aws_vpc.main_vpc.id
  route_table_id = aws_route_table.custom_main_route_table.id
}

