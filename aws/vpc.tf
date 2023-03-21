module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  name               = local.env
  cidr               = "10.0.0.0/16"
  azs                = ["${local.region}a"]
  private_subnets    = ["10.0.1.0/24"]
  public_subnets     = ["10.0.101.0/24"]
  enable_nat_gateway = true
  tags = {
    Terraform = "true"
  }
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}
