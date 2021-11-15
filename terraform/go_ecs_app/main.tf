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

