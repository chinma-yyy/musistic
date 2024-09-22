output "template_id" {
  value = aws_launch_template.ec2_servers.id
}

output "image_id" {
  value = aws_launch_template.ec2_servers.image_id
}
