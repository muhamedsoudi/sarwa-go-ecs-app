output "application_load_balancer" {
  value = aws_lb.application_load_balancer
}

output "alb_security_group" {
  value = aws_security_group.alb_security_group
}