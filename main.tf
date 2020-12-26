# ========= security group ==========

resource "aws_security_group" "security_group" {

  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.open_ports
    content {
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.task_name}-sg"
    Terraform = "true"
  }

}

# ========= service discovery ==========

resource "aws_service_discovery_service" "discovery_name" {

  count = var.has_discovery == false ? 0 : 1
  name  = var.task_name

  dns_config {
    namespace_id = var.dns_namespace

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
}

# ========= task definition ==========

locals {
  log_configuration = {
    "logDriver" = "awslogs"
    "options" = {
      "awslogs-group" : "${var.task_name}-logs"
      "awslogs-create-group" : "true"
      "awslogs-region" : var.logs_region,
      "awslogs-stream-prefix" : var.task_name
    }
  }
}

module "task_definition" {
  source = "github.com/mongodb/terraform-aws-ecs-task-definition"

  name                     = var.task_name
  image                    = var.container_image
  family                   = "${var.task_name}-definition"
  requires_compatibilities = [var.task_launch_type]
  execution_role_arn       = var.task_exec_role
  network_mode             = var.task_network_mode
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  # container port mappings
  portMappings = [
    for port in var.open_ports :
    {
      containerPort = port
      hostPort      = port
      protocol      = "tcp"
    }
  ]

  # container log redirection
  logConfiguration = var.has_logs == true ? local.log_configuration : null

  # environmental variables to pass to the container
  environment = var.environment

  tags = {
    Name      = "${var.task_name}-definition"
    Terraform = "true"
  }

}

resource "aws_ecs_service" "service" {

  name                               = var.task_name
  cluster                            = var.ecs_cluster
  task_definition                    = module.task_definition.arn
  desired_count                      = var.desired_count
  launch_type                        = var.capacity_provider == null ? var.task_launch_type : null
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    security_groups  = concat([aws_security_group.security_group.id], var.security_groups)
    subnets          = var.vpc_subnets
    assign_public_ip = false
  }

  dynamic "service_registries" {
    for_each = var.has_discovery == false ? [] : list(var.has_discovery)
    content {
      registry_arn   = aws_service_discovery_service.discovery_name.arn
      container_name = var.task_name
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.has_asg == false ? [] : list(var.has_asg)
    content {
      capacity_provider = var.capacity_provider
      weight            = 1
    }
  }

  dynamic "load_balancer" {
    for_each = var.has_alb == false ? [] : list(var.has_alb)
    content {
      container_name   = var.task_name
      target_group_arn = var.alb_target_group
      container_port   = var.alb_port
    }
  }

  tags = {
    Name      = "${var.task_name}-service"
    Terraform = "true"
  }

}
