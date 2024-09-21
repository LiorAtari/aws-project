module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = "main-vpc"
  cidr = "10.0.0.0/16"
  azs = ["eu-north-1a", "eu-north-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  intra_subnets = ["10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway = true
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}