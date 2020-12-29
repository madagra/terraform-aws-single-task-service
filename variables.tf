# ========= input variables ==========

variable "task_name" {
  description = "The task name which gives the name to the ECS task, container and service discovery name"
  type        = string
}

variable "container_image" {
  description = "The Docker image to run with the task"
  type        = string
}

variable "ecs_cluster" {
  description = "The ECS cluster ID where the service should run"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the ECS cluster is running"
  type        = string
}

variable "vpc_subnets" {
  description = "The VPC subnets where the application should run"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "The trusted VPC CIDR to assign to the task security group ingress block"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "task_exec_role" {
  description = "The IAM role which is assumed by the ECS tasks"
  type        = string
}

variable "task_launch_type" {
  description = "The launch type for the ECS task. Choose between EC2 and FARGATE"
  type        = string
  default     = "EC2"
}

variable "task_network_mode" {
  description = "The network mode for the ECS task"
  type        = string
  default     = "awsvpc"
}

variable "has_discovery" {
  description = "Flag to switch on service discovery. If true, a valid DNS namespace must be provided"
  type        = bool
  default     = false
}

variable "dns_namespace" {
  description = "The Route53 DNS namespace where the ECS task is registered"
  type        = string
  default     = null
}

variable "open_ports" {
  description = "The ports which should be opened in the container and the security group to allow communication among services"
  type        = list(string)
  default     = []
}

variable "has_alb" {
  description = "Whether the service should be registered to an application load balancer"
  type        = bool
  default     = false
}

variable "alb_port" {
  description = "If load balanced service this is the application port for the target group"
  type        = number
  default     = 0
}

variable "alb_target_group" {
  description = "If the service is associated with an application load balancer this is the ALB target group"
  type        = string
  default     = null
}

variable "has_asg" {
  description = "Whether the service is associated with an autoscaling group of EC2 instances"
  type        = bool
  default     = false
}

variable "capacity_provider" {
  description = "The capacity provider name for the autoscaling group"
  type        = string
  default     = null
}

variable "has_logs" {
  description = "Whether to forward logging to CloudWatch"
  type        = bool
  default     = false
}

variable "logs_region" {
  description = "The region where the CloudWatch logs group is created"
  type        = string
  default     = null
}

variable "task_cpu" {
  description = "The CPU percentage allocated for the ECS task in vCPU units"
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "The memory allocated for the ECS task in Mb"
  type        = number
  default     = 512
}

variable "environment" {
  description = "The container environmental variables"
  type        = list(map(string))
  default     = []
}

variable "security_groups" {
  description = "Additional security groups to assign to the ECS service"
  type        = list(string)
  default     = []
}

variable "desired_count" {
  description = "The desired number of the ECS task to run"
  type        = number
  default     = 1
}

variable "deployment_maximum_percent" {
  description = "The maximum number of tasks which can run during redeployment of the service"
  type        = number
  default     = 100
}

variable "deployment_minimum_healthy_percent" {
  description = "The minimum percentage of running tasks to consider the service healthy"
  type        = number
  default     = 50
}
