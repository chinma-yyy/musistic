module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.cidr_block
  project    = "Rewind"
}

module "public_subnets" {
  source             = "./modules/subnets"
  vpc_id             = module.vpc.vpc_id
  availability_zones = [for s in local.public_subnets : s.az]
  cidr_blocks        = [for s in local.public_subnets : s.cidr]
  type               = "public"
  subnetCount        = length(local.public_subnets)
  project            = "Rewind"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.vpc.igw_id
  }
  tags = {
    Name    = "${var.project}-public-RT"
    Project = var.project
  }
}

resource "aws_route_table_association" "public_association" {
  count = length(module.public_subnets.subnet_ids)

  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = element(module.public_subnets.subnet_ids, count.index)
}

module "private_subnets_L1" {
  source             = "./modules/subnets"
  vpc_id             = module.vpc.vpc_id
  availability_zones = [for s in local.private_subnets_l1 : s.az]
  cidr_blocks        = [for s in local.private_subnets_l1 : s.cidr]
  type               = "private"
  subnetCount        = length(local.private_subnets_l1)
  project            = "Rewind"
}

module "private_subnets_L2" {
  source             = "./modules/subnets"
  vpc_id             = module.vpc.vpc_id
  availability_zones = [for s in local.private_subnets_l2 : s.az]
  cidr_blocks        = [for s in local.private_subnets_l2 : s.cidr]
  type               = "private"
  subnetCount        = length(local.private_subnets_l2)
  project            = "Rewind"
}

module "nat_gateway" {
  source    = "./modules/nat-gateway"
  subnet_id = module.public_subnets.subnet_ids[0]
}

resource "aws_route_table" "private_route_table_L1" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name    = "${var.project}-private-RT-L1"
    Project = var.project
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = module.nat_gateway.nat_id
  }
}

resource "aws_route_table" "private_route_table_L2" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name    = "${var.project}-private-RT-L2"
    Project = var.project
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = module.nat_gateway.nat_id
  }
}

resource "aws_route_table_association" "private_association_L1" {
  count = length(module.private_subnets_L1.subnet_ids)

  route_table_id = aws_route_table.private_route_table_L1.id
  subnet_id      = element(module.private_subnets_L1.subnet_ids, count.index)
}

resource "aws_route_table_association" "private_association_L2" {
  count = length(module.private_subnets_L2.subnet_ids)

  route_table_id = aws_route_table.private_route_table_L2.id
  subnet_id      = element(module.private_subnets_L2.subnet_ids, count.index)
}