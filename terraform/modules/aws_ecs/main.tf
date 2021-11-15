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

# resource "aws_ecs_task_definition" "task" {
#   family = "service"
#   requires_compatibilities = [
#     "FARGATE",
#   ]
#   execution_role_arn = aws_iam_role.fargate.arn
#   network_mode       = "awsvpc"
#   cpu                = var.task_cpu
#   memory             = var.task_memory
#   container_definitions = jsonencode([
#     {
#       name      = var.ecs_container_name
#       image     = var.ecs_container_image
#       essential = true
#       portMappings = [
#         for port in local.container.ports :
#         {
#           containerPort = port
#           hostPort      = port
#         }
#       ]
#     }
#   ])
# }

# resource "aws_ecs_service" "service" {
#   name            = var.ecs_service_name
#   cluster         = aws_ecs_cluster.cluster.id
#   task_definition = aws_ecs_task_definition.task.arn
#   desired_count   = var.ecs_service_desired_count

#   network_configuration {
#     subnets          = var.private_subnets
#     assign_public_ip = false
#   }

#   load_balancer {
#     target_group_arn = var.alb_target_group_arn
#     container_name   = var.ecs_container_name
#     container_port   = var.ecs_container_port
#   }
#   deployment_controller {
#     type = "ECS"
#   }
#   capacity_provider_strategy {
#     base              = 0
#     capacity_provider = "FARGATE"
#     weight            = 100
#   }
# }