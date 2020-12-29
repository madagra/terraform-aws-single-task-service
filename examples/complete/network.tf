# ========= variables ==========

data "aws_availability_zones" "available" {
  state = "available"
}

variable "use_existing_route53_zone" {
  description = "Whether a DNS for the chosen domain is existing or not"
  type        = bool
  default     = true
}

data "aws_route53_zone" "this" {
  count        = var.use_existing_route53_zone ? 1 : 0
  name         = var.domain_name
  private_zone = false
}

# ========= resources ==========

resource "aws_route53_zone" "this" {
  count = ! var.use_existing_route53_zone ? 1 : 0
  name  = var.domain_name
}

module "acm" {

  source = "terraform-aws-modules/acm/aws"

  domain_name = var.domain_name
  zone_id     = coalescelist(data.aws_route53_zone.this.*.zone_id, aws_route53_zone.this.*.zone_id)[0]

  wait_for_validation = true

  tags = {
    Name      = "complete-example-cert"
    Terraform = "true"
  }

}

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