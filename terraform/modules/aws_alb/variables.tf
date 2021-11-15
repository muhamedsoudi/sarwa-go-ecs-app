//----------------------------------------------------------------------
// Shared  Variables
//----------------------------------------------------------------------
variable "tags" {
  description = "tags to propogate to all supported resources"
  type        = map(string)
}

variable "vpc_id" {
}
//----------------------------------------------------------------------
// Security Groups Variables
//----------------------------------------------------------------------

variable "alb_sg_name" {
  description = "Name of the ALB ASG Security Group"
}


//----------------------------------------------------------------------
// Application Load Balancer Variables
//----------------------------------------------------------------------

variable "public_subnets" {
  
}

variable "alb_name" {
  type        = string
  description = "ALB Name"
}
variable "health_check_path" {
  type        = string
  description = "ALB Health Check Path"
}