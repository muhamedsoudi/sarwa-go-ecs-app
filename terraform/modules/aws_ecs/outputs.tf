output "ecs_cluster" {
  value = aws_ecs_cluster.cluster
}

output "ecs_cluster_cw_group" {
  value = aws_cloudwatch_log_group.ecs-cw-log-group
}