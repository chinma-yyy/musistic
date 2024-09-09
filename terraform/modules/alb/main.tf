resource "aws_autoscaling_group" "asg" {
  name             = var.name
  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  launch_template {
    id = var.launch_template_id
  }
  vpc_zone_identifier = var.subnets

  target_group_arns = [aws_lb_target_group.tg.arn]
}

resource "aws_lb" "alb" {
  load_balancer_type = var.load_balancer_type
  internal           = var.private

  security_groups = var.security_groups
  subnets         = var.subnets

  tags = {
    Name = "rewind-${var.name}"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = var.name
  port     = var.port
  protocol = var.protocol
  vpc_id   = var.vpc_id

}

resource "aws_lb_listener" "listener" {
  port              = var.port
  load_balancer_arn = aws_lb.alb.arn
  protocol          = var.protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
