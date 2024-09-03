# Define availability zones and CIDR blocks for public and private subnets
locals {
  public_subnets = [
    { az = local.availability_zone_1, cidr = var.cidr_block_public_1 },
    { az = local.availability_zone_2, cidr = var.cidr_block_public_2 },
  ]

  private_subnets = [
    { az = local.availability_zone_1, cidr = var.cidr_block_private_1a },
    { az = local.availability_zone_1, cidr = var.cidr_block_private_1b },
    { az = local.availability_zone_2, cidr = var.cidr_block_private_2a },
    { az = local.availability_zone_2, cidr = var.cidr_block_private_2b },
  ]
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Define local values for availability zones
locals {
  availability_zone_1 = data.aws_availability_zones.available.names[0]
  availability_zone_2 = data.aws_availability_zones.available.names[1]
}