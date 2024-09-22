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

resource "aws_instance" "instance" {
  instance_type               = "t2.micro"
  key_name                    = "test"
  associate_public_ip_address = true
  ami                         = data.aws_ami.ubuntu_ami.id
}
