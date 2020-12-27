# ========= variables ==========

variable "queue_port" {
  description = "The port to communicate with the message queue"
  type        = number
  default     = 5672
}

variable "backend_port" {
  description = "The port for communicating with the backend"
  type        = number
  default     = 8001
}

variable "ecr_repo" {
  description = "The private ECR repository where container images are stored"
  type        = string
  default     = null
}


# ========= resources ==========

module "sample_app_queue" {

  source = "../../"

  ecs_cluster     = module.ecs_cluster.id
  task_name       = "queue"
  container_image = "rabbitmq:3-management"
  task_exec_role  = module.ecs_cluster.ecs_default_task_role_arn

  vpc_id      = module.vpc.vpc_id
  vpc_subnets = module.vpc.private_subnets

  capacity_provider = module.ecs_cluster.capacity_provider_name

  open_ports = [var.queue_port]
}

module "sample_app_backend" {

  source = "../../"

  ecs_cluster     = module.ecs_cluster.id
  task_name       = "backend"
  container_image = "${var.ecr_repo}/sample-app-backend:latest"
  task_exec_role  = module.ecs_cluster.ecs_default_task_role_arn

  vpc_id      = module.vpc.vpc_id
  vpc_subnets = module.vpc.private_subnets

  capacity_provider = module.ecs_cluster.capacity_provider_name

  open_ports = [var.queue_port, var.backend_port]
  environment = [
    {
      "name" : "EXAMPLE_PORT"
      "value" : "8001"
    }
  ]
}

module "sample_app_frontend" {

  source = "../../"

  ecs_cluster     = module.ecs_cluster.id
  task_name       = "frontend"
  container_image = "${var.ecr_repo}/sample-app-backend:latest"
  task_exec_role  = module.ecs_cluster.ecs_default_task_role_arn

  vpc_id      = module.vpc.vpc_id
  vpc_subnets = module.vpc.private_subnets

  capacity_provider = module.ecs_cluster.capacity_provider_name

  open_ports = [var.queue_port, var.app_port]
  environment = [
    {
      "name" : "EXAMPLE_PORT"
      "value" : "8000"
    }
  ]
}