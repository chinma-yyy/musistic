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

module "security_group_alb" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.vpc_id
  name   = "Alb for server"

  ingress_rules = [
    {
      description = "Allow HTTP"
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_ipv4   = "0.0.0.0/0"
    },
  ]
  egress_rules = [
    {
      description = "Allow all outbound traffic (IPv4)"
      ip_protocol = "-1" # -1 allows all protocols
      from_port   = 0
      to_port     = 0
      cidr_ipv4   = "0.0.0.0/0" # Allows all traffic to all IPv4 addresses
    }
  ]
}
module "security_group_mongodb_alb" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.vpc_id
  name   = "ALB for MongoDB Server"

  ingress_rules = [
    {
      description = "Allow MongoDB (27017) access"
      ip_protocol = "tcp"
      from_port   = 27017
      to_port     = 27017
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound traffic (IPv4)"
      ip_protocol = "-1"
      from_port   = 0
      to_port     = 0
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]
}


module "security_group_bastion_host" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.vpc_id
  name   = "Bastion host for SSH to private instances"

  ingress_rules = [
    {
      description = "Allow SSH from anywhere"
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  egress_rules = [
    {
      description = "Forward SSH to all private instances in the VPC"
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_ipv4   = var.cidr_block
    }
  ]
}

module "security_group_servers" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.vpc_id
  name   = "Servers for application"

  ingress_rules = [
    {
      description                  = "Allow HTTP from ALB"
      referenced_security_group_id = module.security_group_alb.security_group_id
      ip_protocol                  = "tcp"
      from_port                    = 80
      to_port                      = 80
    },
    {
      description                  = "Allow SSH from Bastion Host"
      referenced_security_group_id = module.security_group_bastion_host.security_group_id
      ip_protocol                  = "tcp"
      from_port                    = 22
      to_port                      = 22
    },
  ]
  egress_rules = [
    {
      description = "Allow all outbound traffic (IPv4)"
      ip_protocol = "-1"
      from_port   = 0
      to_port     = 0
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]
}

module "security_group_mongodb" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.vpc_id
  name   = "MongoDB Security Group"

  ingress_rules = [
    {
      description = "Allow MongoDB access from trusted IPs"
      ip_protocol = "tcp"
      from_port   = 27017
      to_port     = 27017
      cidr_ipv4   = var.cidr_block
    },
    {
      description = "Allow EFS access from EC2 instances"
      ip_protocol = "tcp"
      from_port   = 2049
      to_port     = 2049
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  egress_rules = [
    {
      description = "Allow MongoDB outgoing traffic to all instances in the VPC"
      ip_protocol = "tcp"
      from_port   = 27017
      to_port     = 27017
      cidr_ipv4   = var.cidr_block
    }
  ]
}

module "iam_role" {
  source = "./modules/iam"
}

module "launch_template_server" {
  source             = "./modules/launch-templates"
  template_name      = "Server template"
  description        = "Template for the rest API server"
  user_data          = "scripts/server.sh"
  security_group_ids = [module.security_group_servers.security_group_id]
  policy_name        = module.iam_role.policy_name
}

module "launch_template_socket" {
  source             = "./modules/launch-templates"
  template_name      = "Socket template"
  description        = "Template for the rest socket server"
  user_data          = "scripts/socket.sh"
  security_group_ids = [module.security_group_servers.security_group_id]
  policy_name        = module.iam_role.policy_name
}

module "launch_template_frontend" {
  source             = "./modules/launch-templates"
  template_name      = "Frontend template"
  description        = "Template for the frontend of the app"
  user_data          = "scripts/frontend.sh"
  security_group_ids = [module.security_group_servers.security_group_id]
  policy_name        = module.iam_role.policy_name
}

resource "aws_efs_file_system" "mongodb_efs" {
  tags = {
    Name = "${var.project}-mongo-efs"
  }
}

module "launch_template_mongodb" {
  source             = "./modules/launch-templates"
  template_name      = "MongoDB template"
  description        = "Template for the mongodb servers"
  user_data          = "scripts/mongo.sh"
  security_group_ids = [module.security_group_mongodb.security_group_id]
  policy_name        = module.iam_role.policy_name
  efs_file_system_id = aws_efs_file_system.mongodb_efs.id
}

# resource "aws_elasticache_subnet_group" "redis_subnets" {
#   name       = "redis-subnets"
#   subnet_ids = module.private_subnets_L2.subnet_ids

#   tags = {
#     Name = "Redis-subnets"
#   }
# }

# resource "aws_elasticache_cluster" "redis" {
#   cluster_id      = "redis-rewind"
#   node_type       = "cache.t3.micro"
#   num_cache_nodes = 1
#   engine          = "redis"

#   subnet_group_name = aws_elasticache_subnet_group.redis_subnets.name
# }

module "alb_server" {
  source             = "./modules/alb"
  name               = "server"
  vpc_id             = module.vpc.vpc_id
  launch_template_id = module.launch_template_server.template_id
  private            = false
  availability_zones = [local.availability_zone_1, local.availability_zone_2]
  security_groups    = [module.security_group_alb.security_group_id]
  subnets            = module.public_subnets.subnet_ids
}

resource "aws_autoscaling_group" "asg" {
  name             = "socket"
  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  launch_template {
    id = module.launch_template_socket.template_id
  }
  vpc_zone_identifier = module.public_subnets.subnet_ids

  target_group_arns = [aws_lb_target_group.socket_tg.arn]
}

resource "aws_lb_target_group" "socket_tg" {
  name     = "socket"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_lb_listener_rule" "rule" {
  listener_arn = module.alb_server.listener_arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.socket_tg.arn
  }
  condition {
    path_pattern {
      values = ["/socket.io*"]
    }
  }
}

module "alb_frontend" {
  source             = "./modules/alb"
  name               = "frontend"
  vpc_id             = module.vpc.vpc_id
  launch_template_id = module.launch_template_frontend.template_id
  private            = false
  availability_zones = [local.availability_zone_1, local.availability_zone_2]
  security_groups    = [module.security_group_alb.security_group_id]
  subnets            = module.public_subnets.subnet_ids
}

module "nlb_mongodb" {
  source             = "./modules/alb"
  name               = "mongodb"
  vpc_id             = module.vpc.vpc_id
  launch_template_id = module.launch_template_mongodb.template_id
  private            = true
  subnets            = module.private_subnets_L1.subnet_ids
  availability_zones = [local.availability_zone_1, local.availability_zone_2]
  security_groups    = [module.security_group_mongodb_alb.security_group_id]
  port               = 27017
  protocol           = "TCP"
  load_balancer_type = "network"
}

data "aws_route53_zone" "chinmayyy" {
  name = "chinmayyy.me."
}

resource "aws_route53_record" "frontend" {
  name    = "rewind.chinmayyy.me"
  zone_id = data.aws_route53_zone.chinmayyy.id
  type    = "A"
  alias {
    name                   = module.alb_frontend.dns_name
    zone_id                = module.alb_frontend.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "backend" {
  name    = "backend.chinmayyy.me"
  zone_id = data.aws_route53_zone.chinmayyy.id
  type    = "A"
  alias {
    name                   = module.alb_server.dns_name
    zone_id                = module.alb_server.zone_id
    evaluate_target_health = true
  }
}

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

resource "aws_instance" "baston_host" {
  instance_type               = "t2.micro"
  ami                         = data.aws_ami.ubuntu_ami.id
  associate_public_ip_address = true
  availability_zone           = local.availability_zone_1
  security_groups             = [module.security_group_bastion_host.security_group_id]
  key_name                    = "test"
  subnet_id                   = module.public_subnets.subnet_ids[0]
  tags = {
    Name = "bastion host for all the vpc instances"
  }

  provisioner "file" {
    source      = "${path.root}/test.pem"
    destination = "/home/ubuntu/test.pem"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.root}/test.pem") # Path to your SSH private key
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
      private_key = file("${path.root}/test.pem") # Path to your SSH private key
      host        = self.public_ip
    }
  }
}



