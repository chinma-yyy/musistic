data "aws_ami" "ubuntu_ami" {
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-0a0e5d9c7acc336f1"]
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


  user_data = base64encode(
    length(var.efs_file_system_id) > 0 ?
    replace(file("${path.root}/${var.user_data}"), "$${efs_file_system_id_placeholder}", var.efs_file_system_id) :
    file("${path.root}/${var.user_data}")
  )

  iam_instance_profile {
    name = var.policy_name

  }
  vpc_security_group_ids = var.security_group_ids

  key_name = "test"
  tags = {
    Name = var.template_name
  }
}

