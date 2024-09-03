resource "aws_subnet" "subnet" {
  count                   = var.subnetCount
  vpc_id                  = var.vpc_id
  availability_zone       = element(var.availability_zones, count.index)
  cidr_block              = element(var.cidr_blocks, count.index)
  map_public_ip_on_launch = var.type == "public" ? true : false

  tags = {
    Name = "${var.type}-subnet"
    Project = "${var.project}"
  }
}