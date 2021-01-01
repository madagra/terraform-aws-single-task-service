# ========= variables ==========

data "aws_availability_zones" "available" {
  state = "available"
}

# ========= resources ==========

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.48.0"

  name = "example_vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_ipv6          = false
  enable_nat_gateway   = true
  enable_vpn_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = "complete-example-vpc"
    Terraform = "true"
  }
}