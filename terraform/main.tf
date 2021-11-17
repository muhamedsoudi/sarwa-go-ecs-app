
data "aws_caller_identity" "current" {}

locals {
 image_url = "${format("%s:%s",module.ecr.ecr_repo_url,"latest")}" 
}

module "vpc" {
  source   = "./modules/aws_vpc/"
  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
  az_count = var.az_count
  enable_private_subnets = var.enable_private_subnets
  private_subnet_size = var.private_subnet_size
  enable_public_subnets = var.enable_public_subnets
  public_subnet_size = var.public_subnet_size
  tags     = var.tags
}

module "alb" {
  source   = "./modules/aws_alb/"
  vpc_id = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  alb_name = var.alb_name
  health_check_path = var.health_check_path
  alb_sg_name = var.alb_sg_name
  alb_port = var.alb_port
  container_port = var.container_port
  tags     = var.tags
}

# Create ECR Repository, build and push docker image to it 
module "ecr" {
  source = "./modules/aws_ecr/"
  account_no = data.aws_caller_identity.current.account_id
  ecr_repo_name = var.ecr_repo_name
  dockerfile_dir = "../"
  region = var.region
  tags     = var.tags
}

module "ecs" {
  source   = "./modules/aws_ecs/"
  ecs_cluster_name = var.ecs_cluster_name
  tags     = var.tags
  task_defination_name = var.task_defination_name
  task_cpu = var.task_cpu
  task_memory = var.task_memory
  image_url = local.image_url
  container_name = var.container_name
  container_memory = var.container_memory
  region = var.region
  vpc_id = module.vpc.vpc_id
  container_port = var.container_port
  alb_target_group_arn = module.alb.alb_target_group_arn
  private_subnets = module.vpc.private_subnets
  ecs_service_desired_count = var.ecs_service_desired_count
  alb_sg_id = module.alb.alb_security_group.id
  ecs_service_sg_name = var.ecs_service_sg_name
  ecs_service_name = var.ecs_service_name
}

module "codepipeline" {
  source   = "./modules/aws_cicd/"
  ecs_cluster_name = var.ecs_cluster_name
  region = var.region
  aws_account_no = data.aws_caller_identity.current.account_id
  tags   = var.tags
  codepipeline_name = var.codepipeline_name
  ecs_service_name = var.ecs_service_name
  codebuild_project_name = var.codebuild_project_name
  ecr_repo_arn = module.ecr.ecr_repo_arn
  ecr_repo_url = module.ecr.ecr_repo_url
  github_branch_name = var.github_branch_name
  github_username = var.github_username
  github_repo_name = var.github_repo_name
  webhook_secret = var.webhook_secret
  github_token = var.github_token
}
