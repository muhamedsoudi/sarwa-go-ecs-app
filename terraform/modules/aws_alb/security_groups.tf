resource "aws_security_group" "alb_security_group" {
  name        = var.alb_sg_name
  description = "Allow Traffic to Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
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
      "Name" = var.alb_sg_name
    },
  )
}

