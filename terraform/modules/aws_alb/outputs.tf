output "application_load_balancer" {
  value = aws_lb.application_load_balancer
}

output "alb_dns_name" {
  value = aws_lb.application_load_balancer.dns_name
}

output "alb_security_group" {
  value = aws_security_group.alb_security_group
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.target_group.arn
}