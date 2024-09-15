data "aws_elb_service_account" "main" {
  region = var.region
}

resource "aws_s3_bucket" "elb_logs" {
  bucket = "logs-rewind"
}

# resource "aws_s3_bucket_acl" "elb_logs_acl" {
#   bucket = aws_s3_bucket.elb_logs.id
#   acl    = "private"
# }

data "aws_iam_policy_document" "allow_elb_logging" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.elb_logs.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "allow_elb_logging" {
  bucket = aws_s3_bucket.elb_logs.id
  policy = data.aws_iam_policy_document.allow_elb_logging.json
}


resource "aws_elasticache_subnet_group" "redis_subnets" {
  name       = "redis-subnets"
  subnet_ids = module.private_subnets_L2.subnet_ids

  tags = {
    Name = "Redis-subnets"
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id         = "redis-rewind"
  node_type          = "cache.t3.micro"
  num_cache_nodes    = 1
  engine             = "redis"
  security_group_ids = [module.security_group_redis.security_group_id]
  subnet_group_name  = aws_elasticache_subnet_group.redis_subnets.name
}

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
      description = "Allow HTTPS"
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_ipv4   = "0.0.0.0/0"
    },
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
      from_port   = -1
      to_port     = -1
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
      from_port   = -1
      to_port     = -1
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
    {
      description = "Allow Redis traffic"
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "tcp"
      from_port   = aws_elasticache_cluster.redis.cache_nodes[0].port
      to_port     = aws_elasticache_cluster.redis.cache_nodes[0].port
    }
  ]
  egress_rules = [
    {
      description = "Allow all outbound traffic (IPv4)"
      ip_protocol = "-1"
      from_port   = -1
      to_port     = -1
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
      from_port   = -1
      to_port     = -1
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]
}

module "security_group_redis" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.vpc_id
  name   = "Security group for redis rewind"

  ingress_rules = [
    {
      description                  = "Allow redis access for servers"
      ip_protocol                  = "tcp"
      from_port                    = aws_elasticache_cluster.redis.cache_nodes[0].port
      to_port                      = aws_elasticache_cluster.redis.cache_nodes[0].port
      referenced_security_group_id = module.security_group_servers.security_group_id
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound traffic (IPv4)"
      ip_protocol = "-1"
      from_port   = -1
      to_port     = -1
      cidr_ipv4   = "0.0.0.0/0"
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
  instance_type      = "t3.small"
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

data "aws_acm_certificate" "ssl_certficate" {
  domain = "*.chinmayyy.me"
}

module "alb_server" {
  source             = "./modules/alb"
  name               = "server"
  vpc_id             = module.vpc.vpc_id
  launch_template_id = module.launch_template_server.template_id
  private            = false
  availability_zones = [local.availability_zone_1, local.availability_zone_2]
  security_groups    = [module.security_group_alb.security_group_id]
  subnets            = module.public_subnets.subnet_ids
  instances_subnets  = module.private_subnets_L1.subnet_ids
  port               = 443
  protocol           = "HTTPS"
  certificate_arn    = data.aws_acm_certificate.ssl_certficate.arn
  path               = "/test"
  port_tg            = 80
  protocol_tg        = "HTTP"
  bucket_id          = aws_s3_bucket.elb_logs.id
  bucket_prefix      = "server"
  depends_on = [aws_secretsmanager_secret_version.server_secret_update,
    aws_secretsmanager_secret_version.socket_secret_update,
    data.aws_acm_certificate.ssl_certficate,
  aws_s3_bucket_policy.allow_elb_logging]
}

resource "aws_autoscaling_group" "asg" {
  name             = "socket"
  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  launch_template {
    id = module.launch_template_socket.template_id
  }
  vpc_zone_identifier = module.private_subnets_L1.subnet_ids

  target_group_arns = [aws_lb_target_group.socket_tg.arn]
  depends_on        = [module.nat_gateway.nat_id]
}

resource "aws_lb_target_group" "socket_tg" {
  name     = "socket"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    path = "/test"
  }
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
  instances_subnets  = module.private_subnets_L1.subnet_ids
  port_tg            = 80
  protocol_tg        = "HTTP"
  bucket_id          = aws_s3_bucket.elb_logs.id
  bucket_prefix      = "frontend"
  depends_on         = [module.nat_gateway.nat_id, aws_s3_bucket_policy.allow_elb_logging]
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
  port_tg            = 27017
  protocol_tg        = "TCP"
  bucket_id          = aws_s3_bucket.elb_logs.id
  bucket_prefix      = "mongodb"
  instances_subnets  = module.private_subnets_L2.subnet_ids
  depends_on         = [aws_s3_bucket_policy.allow_elb_logging, module.nat_gateway]
}

data "aws_route53_zone" "chinmayyy" {
  name = "chinmayyy.me."
}

resource "aws_route53_record" "frontend" {
  name    = "rewind.chinmayyy.me"
  zone_id = data.aws_route53_zone.chinmayyy.id
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.frontend_cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_cloudfront.hosted_zone_id
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
  lifecycle {
    ignore_changes = [
      security_groups
    ]
  }
}

data "aws_secretsmanager_secret" "socket_secret" {
  name = "rewind/backend/sockets"
}

data "aws_secretsmanager_secret" "server_secret" {
  name = "rewind/backend/server"
}

data "aws_secretsmanager_secret_version" "existing_server_secret" {
  secret_id = data.aws_secretsmanager_secret.server_secret.id
}

data "aws_secretsmanager_secret_version" "existing_socket_secret" {
  secret_id = data.aws_secretsmanager_secret.socket_secret.id
}

resource "aws_secretsmanager_secret_version" "socket_secret_update" {
  secret_id = data.aws_secretsmanager_secret.socket_secret.id
  secret_string = jsonencode(
    merge(
      jsondecode(data.aws_secretsmanager_secret_version.existing_socket_secret.secret_string),
      {
        MONGODB_URL = "mongodb://admin:Password@123@${module.nlb_mongodb.dns_name}:27017/"
      }
    )
  )
  depends_on = [module.nlb_mongodb]
}

resource "aws_secretsmanager_secret_version" "server_secret_update" {
  secret_id = data.aws_secretsmanager_secret.server_secret.id
  secret_string = jsonencode(
    merge(
      jsondecode(data.aws_secretsmanager_secret_version.existing_server_secret.secret_string),
      {
        MONGO_URL  = "mongodb://admin:Password%40123@${module.nlb_mongodb.dns_name}:27017/",
        REDIS_HOST = "${aws_elasticache_cluster.redis.cache_nodes[0].address}",
        REDIS_PORT = "${aws_elasticache_cluster.redis.cache_nodes[0].port}",
        REDIS_TLS  = "true"
      }
    )
  )

  depends_on = [aws_elasticache_cluster.redis, module.nlb_mongodb]
}

resource "aws_cloudfront_distribution" "frontend_cloudfront" {
  enabled = true
  aliases = ["rewind.chinmayyy.me"]
  origin {
    domain_name = module.alb_frontend.dns_name
    origin_id   = "rewind_frontend"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.ssl_certficate.arn
    ssl_support_method  = "sni-only"

  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["IN"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "rewind_frontend"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    min_ttl         = 0
    default_ttl     = 3600  # Cache duration (1 hour)
    max_ttl         = 86400 # Maximum cache duration (1 day)
    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100" # Adjust based on your needs (PriceClass_100 is the cheapest)
}


