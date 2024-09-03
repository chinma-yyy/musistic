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

module "private_subnets" {
  source             = "./modules/subnets"
  vpc_id             = module.vpc.vpc_id
  availability_zones = [for s in local.private_subnets : s.az]
  cidr_blocks        = [for s in local.private_subnets : s.cidr]
  type               = "private"
  subnetCount        = length(local.private_subnets)
  project            = "Rewind"
}
