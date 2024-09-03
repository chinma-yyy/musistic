output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "igw_id" {
  value = aws_internet_gateway.gw.id
}

output "main_rt_id" {
  value = aws_route_table.custom_main_route_table.id
}
