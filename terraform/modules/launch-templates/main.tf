data "aws_ami" "ubuntu_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_launch_template" "ec2_servers" {
  description   = var.description
  instance_type = "t2.micro"
  image_id      = data.aws_ami.ubuntu_ami.id


  user_data = filebase64("${path.cwd}/${var.user_data}")

  iam_instance_profile {
    name = "secrets_role_ec2"
  }
  vpc_security_group_ids = var.security_group_ids

  tags = {
    Name = var.template_name
  }
}
