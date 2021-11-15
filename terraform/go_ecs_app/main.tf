
data "aws_caller_identity" "current" {}

module "vpc" {
  source   = "../modules/aws_vpc/"
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
  source   = "../modules/aws_alb/"
  vpc_id = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  alb_name = var.alb_name
  health_check_path = var.health_check_path
  alb_sg_name = var.alb_sg_name
  tags     = var.tags
}

# Create ECR Repository, build and push docker image to it 
module "ecr" {
  source = "../modules/aws_ecr/"
  account_no = data.aws_caller_identity.current.account_id
  ecr_repo_name = var.ecr_repo_name
  dockerfile_dir = "../../"
  region = var.region
  tags     = var.tags
}

module "ecs" {
  source   = "../modules/aws_ecs/"
  ecs_cluster_name = var.ecs_cluster_name
  tags     = var.tags
}



