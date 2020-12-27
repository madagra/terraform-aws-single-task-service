# ========= variables ==========

variable "app_port" {
  description = "The port where it runs the qubec API server"
  default     = 8000
}

variable "domain_name" {
  description = "The domain name where the application is going to run"
  type        = string
  default     = "example.com"
}

variable "profile" {
  description = "The AWS profile configured locally"
  type        = string
  default     = "default"
}

variable "region" {
  description = "The AWS region where to start the ECS service"
  type        = string
  default     = "us-east-1"
}

# ========= providers ==========

provider "aws" {
  region  = var.region
  profile = var.profile
}
