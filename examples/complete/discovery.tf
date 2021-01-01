# ========= variables ==========

variable "alb_name" {
  description = "Name of the ALB"
  type        = string
  default     = "example-alb"
}

variable "namespace" {
  type    = string
  default = "sample_app"
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

resource "aws_route53_record" "dns_record" {
  zone_id = coalescelist(data.aws_route53_zone.this.*.zone_id, aws_route53_zone.this.*.zone_id)[0]
  name    = coalescelist(data.aws_route53_zone.this.*.name, aws_route53_zone.this.*.name)[0]
  type    = "A"
  alias {
    name                   = module.alb.this_lb_dns_name
    zone_id                = module.alb.this_lb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_security_group" "alb_sg" {

  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = var.app_port
    to_port     = var.app_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "complete-example-sg-alb"
    Terraform = "true"
  }

}

module "alb" {

  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.10.0"

  name               = var.alb_name
  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.alb_sg.id]

  target_groups = [
    {
      backend_protocol = "HTTP"
      backend_port     = var.app_port
      target_type      = "ip"
      "health_check" = {
        enabled = true,
        path    = "/"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      target_group_index = 0
      certificate_arn    = module.acm.this_acm_certificate_arn
    }
  ]

  tags = {
    Name      = "complete-example-alb"
    Terraform = "true"
  }
}

resource "aws_service_discovery_private_dns_namespace" "dns_namespace" {
  name        = var.namespace
  description = "Complete example service discovery namespace"
  vpc         = module.vpc.vpc_id

  tags = {
    Name      = "complete-example-srv-discovery"
    Terraform = "true"
  }
}