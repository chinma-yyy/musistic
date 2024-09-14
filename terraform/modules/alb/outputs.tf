output "tg_arn" {
  value = aws_lb_target_group.tg.arn
}

output "listener_arn" {
  value = var.protocol == "HTTPS" ? aws_lb_listener.https_listener[0].arn : aws_lb_listener.listener[0].arn
}


output "dns_name" {
  value = aws_lb.alb.dns_name
}

output "zone_id" {
  value = aws_lb.alb.zone_id
}
