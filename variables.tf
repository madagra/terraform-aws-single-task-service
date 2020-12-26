# ========= input variables ==========

variable "task_name" {
  description = "The task name which gives the name to the task, container and service discovery"
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
  description = "The Route53 DNS namespace to be used by the service discovery mechanism"
  type        = string
  default     = null
}

variable "open_ports" {
  description = "The ports which should be opened in the container and the security group to allow communication among services"
  type        = list(string)
  default     = []
}

variable "has_alb" {
  description = "If the load balancer should point to the service or not"
  type        = bool
  default     = false
}

variable "alb_port" {
  description = "If load balanced service this is the application port for the target group"
  type        = number
  default     = 0
}

variable "alb_target_group" {
  description = "If load balanced service this is the target group"
  type        = string
  default     = null
}

variable "has_asg" {
  description = "Flag to determine if the create service is associated with an autoscaling group of EC2 instances"
  type        = bool
  default     = false
}

variable "capacity_provider" {
  description = "The capacity provider name for the autoscaling group"
  type        = string
  default     = null
}

variable "has_logs" {
  description = "Whether to forward logging to CloudWatch or not"
  type        = bool
  default     = false
}

variable "logs_region" {
  description = "The region where to create the CloudWatch logs group"
  type        = string
  default     = null
}

variable "task_cpu" {
  description = "The CPU percentage allocated for the task"
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "The memory allocated for the task"
  type        = number
  default     = 512
}

variable "environment" {
  description = "The container environmental variables"
  type        = list(map(string))
  default     = []
}

variable "security_groups" {
  type    = list(string)
  default = []
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "deployment_maximum_percent" {
  type    = number
  default = 100
}

variable "deployment_minimum_healthy_percent" {
  type    = number
  default = 50
}
