terraform {
  required_version = ">= 1.0.11"
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
}

