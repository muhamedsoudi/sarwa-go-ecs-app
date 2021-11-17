output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "igw_id" {
  value = module.vpc.igw_id
}

output "public_routes" {
  value = module.vpc.public_routes
}

output "private_routes" {
  value = module.vpc.private_routes
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr
}

output "ecr_repo_url" {
  value = module.ecr.ecr_repo_url
}

output "image_url" {
  value = "${format("%s:%s",module.ecr.ecr_repo_url,"latest")}"
}

output "alb_dns_name" {
  value = "${format("%s:%s",module.alb.alb_dns_name,var.alb_port)}"
}
