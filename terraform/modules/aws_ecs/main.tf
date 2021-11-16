##################################
# Amazon ECS Module
##################################

resource "aws_ecs_cluster" "cluster" {
  name               = var.ecs_cluster_name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = "100"
  }

  configuration {
    execute_command_configuration {
      logging    = "OVERRIDE"
      log_configuration {
        cloud_watch_encryption_enabled = false
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs-cw-log-group.name
      }
    }
  }

    tags = merge(
    var.tags,
    {
      "Name" = var.ecs_cluster_name
    },
  )
}

# Cloudwatch to store logs
resource "aws_cloudwatch_log_group" "ecs-cw-log-group" {
  name = "${var.ecs_cluster_name}-cw-LogGroup"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.ecs_cluster_name}-cw-LogGroup"
    },
  )
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.task_defination_name
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu 
  memory                   = var.task_memory
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      image     = var.image_url
      name      = var.container_name
      memory    = var.container_memory
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options  = {
          awslogs-region = var.region
          awslogs-group  = aws_cloudwatch_log_group.ecs-cw-log-group.name
          awslogs-stream-prefix = "ecs-${var.container_name}"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = var.ecs_service_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ecs_service_security_group.id]
    subnets          = var.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

}