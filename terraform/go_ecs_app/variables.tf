variable "region" {
  default = "us-east-1"
}

variable "tags" {
  description = "Tags to propogate to all supported resources"
  type        = map(string)
  default = {
    environment  = "go-ecs-app"
    managed-by   = "Terraform"
    owner        = "MuhamadSaudi"
  }
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC being deployed"
  default     = "go-ecs-app-vpc"
}

variable "vpc_cidr" {
  type        = string
  description = "IP CIDR assigned to the environment"
  default     = "10.60.60.0/22"
}
variable "az_count" {
  description = "the number of AZs to deploy infrastructure to"
  default     = 2
}

variable "private_subnet_size" {
  default = 24
}

variable "public_subnet_size" {
  default = 25
}

variable "enable_public_subnets" {
  type    = string
  default = "true"
}

variable "enable_private_subnets" {
  type    = string
  default = "true"
}

//----------------------------------------------------------------------
// Application Load Balancer Variables
//----------------------------------------------------------------------

variable "alb_name" {
  type        = string
  description = "ALB Name"
  default     = "go-ecs-app"
}
variable "alb_sg_name" {
  description = "Name of the ALB ASG Security Group"
  default     = "external_alb_sg"
}

variable "health_check_path" {
  type        = string
  description = "ALB Health Check Path"
  default     = "/"
}
//----------------------------------------------------------------------
// ECS Variables
//----------------------------------------------------------------------

variable "ecs_cluster_name" {
  type        = string
  description = "ECS Cluster Name"
  default     = "go-app-ecs-cluster"
}
variable "ecr_repo_name" {
  type        = string
  description = "ECR Repository Name"
  default     = "go-app-repo"
}