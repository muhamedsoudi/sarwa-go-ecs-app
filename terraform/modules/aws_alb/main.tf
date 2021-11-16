##################################
# Application Load Balancer Module
##################################

resource "aws_lb" "application_load_balancer" {
  name               = "external-${var.alb_name}-alb"
  internal           = "false"
  load_balancer_type = "application"
  subnets                          = var.public_subnets
  enable_cross_zone_load_balancing = "true"
  security_groups                  = [aws_security_group.alb_security_group.id]
  idle_timeout                     = 60

  tags = merge(
    var.tags,
    {
      "Name" = "external-${var.alb_name}-alb"
    },
  )
}

resource "aws_lb_listener" "listener_target_group" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = var.alb_port
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.target_group.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "target_group" {
  name_prefix = "ext-tg"
  port     = var.alb_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type       = "ip"
  health_check {
    interval = "20"
    port     = var.container_port
    protocol = "HTTP"
    path     = var.health_check_path
    healthy_threshold = 2
  }
  lifecycle {
        create_before_destroy = true
  }
  tags = merge(
    var.tags,
    {
      "Name" = "external-${var.alb_name}-lb-tg"
    },
  )
}