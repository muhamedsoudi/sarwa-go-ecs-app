resource "aws_security_group" "ecs_service_security_group" {
  name        = var.ecs_service_sg_name
  description = "Allow Traffic to ESC service on container port only from Application Load Balancer SG"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "TCP"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.ecs_service_sg_name
    },
  )
}

