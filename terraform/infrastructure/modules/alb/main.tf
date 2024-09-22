resource "aws_autoscaling_group" "asg" {
  name             = var.name
  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  launch_template {
    id = var.launch_template_id
  }
  vpc_zone_identifier = var.instances_subnets

  target_group_arns = [aws_lb_target_group.tg.arn]
}

resource "aws_lb" "alb" {
  load_balancer_type = var.load_balancer_type
  internal           = var.private

  security_groups = var.security_groups
  subnets         = var.subnets
  # access_logs {
  #   bucket  = var.bucket_id
  #   prefix  = "${var.bucket_prefix}/access"
  #   enabled = true
  # }
  # connection_logs {
  #   bucket  = var.bucket_id
  #   prefix  = "${var.bucket_prefix}/conn"
  #   enabled = true
  # }
  tags = {
    Name = "rewind-${var.name}"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = var.name
  port     = var.port_tg
  protocol = var.protocol_tg
  vpc_id   = var.vpc_id
  health_check {
    path = var.path
  }
}

resource "aws_lb_listener" "listener" {
  port              = var.port
  load_balancer_arn = aws_lb.alb.arn
  protocol          = var.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  # This part will apply to non-HTTPS protocols only
  count = var.protocol == "HTTPS" ? 0 : 1
}

resource "aws_lb_listener" "https_listener" {
  port              = var.port
  load_balancer_arn = aws_lb.alb.arn
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn

  }

  # Only create this resource if protocol is HTTPS
  count = var.protocol == "HTTPS" ? 1 : 0
}


