# ========= variables ==========

variable "cluster_name" {
  description = "The ECS cluster to start the instances in"
  type        = string
  default     = "example_cluster"
}

# ========= resources ==========

module "ecs_cluster" {
  source       = "github.com/jetbrains-infra/terraform-aws-ecs-cluster?ref=v0.4.8"
  cluster_name = var.cluster_name
  spot         = true
  instance_types = {
    "t3.small" = 1
  }
  target_capacity = 100

  trusted_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  subnets_ids         = module.vpc.private_subnets

  tags = {
    Name      = "complete-example-cluster"
    Terraform = "true"
  }
}