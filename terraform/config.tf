terraform {
  required_version = ">= 1.0.11"
  required_providers {
    aws = ">= 3.65.0"
  }
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
}


