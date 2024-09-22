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


data "aws_vpc" "default" {
  default = true
}
resource "aws_security_group" "master_node_sg" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "master_ir_ssh" {
  security_group_id = aws_security_group.master_node_sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow ssh from anywhere"
}


resource "aws_vpc_security_group_ingress_rule" "master_ir_http" {
  security_group_id = aws_security_group.master_node_sg.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow http from anywhere"
}


resource "aws_vpc_security_group_egress_rule" "default_master" {
  security_group_id = aws_security_group.master_node_sg.id
  ip_protocol       = "-1"
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all traffic from all the ports to all portss"
  tags = {
    jenkins : "Rewind",
    type : "master"
  }
}


resource "aws_security_group" "slave_node_sg" {
  vpc_id = data.aws_vpc.default.id
}
resource "aws_vpc_security_group_ingress_rule" "slave_ir" {
  security_group_id            = aws_security_group.slave_node_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.master_node_sg.id
  description                  = "allow ssh from only the master node"
}

resource "aws_vpc_security_group_egress_rule" "default_slave" {
  security_group_id = aws_security_group.slave_node_sg.id
  ip_protocol       = "-1"
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all traffic from all the ports to all portss"
  tags = {
    jenkins : "Rewind",
    type : "slave"
  }
}

resource "aws_instance" "master_node" {
  instance_type               = "t2.small"
  ami                         = data.aws_ami.ubuntu_ami.id
  associate_public_ip_address = true
  key_name                    = "test"
  vpc_security_group_ids      = [aws_security_group.master_node_sg.id]

  # Provisioning steps for the master node
  provisioner "file" {
    source      = "${path.root}/test.pem"
    destination = "/home/ubuntu/test.pem"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.root}/test.pem")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ubuntu/test.pem"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.root}/test.pem")
      host        = self.public_ip
    }
  }

  # Script to set up Jenkins
  provisioner "file" {
    source      = "${path.root}/scripts/jenkins.sh"
    destination = "/home/ubuntu/jenkins.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.root}/test.pem")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/jenkins.sh",
      "/home/ubuntu/jenkins.sh"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.root}/test.pem")
      host        = self.public_ip
    }
  }
}

# Slave node provisioning can start once the master node has a public IP
resource "aws_instance" "slave_node" {
  instance_type               = "t3.small"
  ami                         = data.aws_ami.ubuntu_ami.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.slave_node_sg.id]
  key_name                    = "test"

  # SSH through the master node (bastion) for provisioning
  provisioner "file" {
    source      = "${path.root}/scripts/docker.sh"
    destination = "/home/ubuntu/docker.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.root}/test.pem")
      host        = self.private_ip

      # Bastion SSH via master node's public IP
      bastion_host        = aws_instance.master_node.public_ip
      bastion_user        = "ubuntu"
      bastion_private_key = file("${path.root}/test.pem")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/docker.sh",
      "/home/ubuntu/docker.sh"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.root}/test.pem")
      host        = self.private_ip

      # Bastion SSH via master node's public IP
      bastion_host        = aws_instance.master_node.public_ip
      bastion_user        = "ubuntu"
      bastion_private_key = file("${path.root}/test.pem")
    }
  }

  # Dependency only on SSH accessibility via master node (bastion host)
  depends_on = [
    aws_instance.master_node
  ]
}

