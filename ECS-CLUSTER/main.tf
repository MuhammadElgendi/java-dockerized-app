provider "aws" {
  region = "us-west-1"
}

# Include necessary modules
module "vpc" {
  source = "./vpc"
  public_subnet_count  = 2
  public_subnet_cidrs  = var.public_subnet_cidr_blocks 
  private_subnet_count = 2
  private_subnet_cidrs = var.private_subnet_cidr_blocks
  availability_zones   = var.availability_zones
}

module "iam_user" {
  source = "./iam_user"
}

module "ecr" {
  source = "./ecr"
}

module "ecs" {
  source = "./ecs"
  # vpc_id = module.vpc.vpc_id
  subnets = module.vpc.private_subnets
  repository_url = module.ecr.repository_url
  security_group_id = module.vpc.security_group_id
}
