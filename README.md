# Single task ECS service provisioning with Terraform
 
This is yet another module to run containerized applications on AWS ECS using Terraform 
for infrastructure provisioning. This module is built for deploying ECS services running tasks 
with a single container definition within a VPC. Optionally service discovery namespace 
and autoscaling groups can also be specified as input. 

This module simplifies several steps in the creation of an ECS service with a single container task
definition and it is therefore not suitable if one needs fine-grained tuning of the container 
definition and security properties.

## Usage

The module can be used for creating a simple service as follows: 

```hcl

provider "aws" { }

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
}

module "sample_app" {

  source = "github.com/madagra/terraform-aws-single-task-service"

  task_name       = "sample_app"
  vpc_id          = module.vpc.vpc_id
  vpc_subnets     = module.vpc.private_subnets
  task_exec_role  = aws_iam_role.ecs_execution.arn

  has_discovery = true
  dns_namespace = aws_service_discovery_private_dns_namespace.sample_namespace.id

  open_ports      = [80, 8080]
  ecs_cluster     = "ecs_cluster"
  container_image = "python:3.8-slim"

  environment = [
    {
      "name" : "EXAMPLE_ENV"
      "value" : "sample"
    }
  ]
}

```

More complete examples can be found in the `examples/` folder which contains:

* `examples/basic`: A basic example of an ECS service with minimal features
provisioned with the module.
* `example/python`: A sample Python application which can be used for testing
the module with multiple communicating services.

## Providers

| Name | Version |
|------|---------|
| aws  | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| task_name | The name of the service which is used also in service discovery name and task definition family | `string` | n/a | yes |
| container_image | The Docker image to run within the ECS task | `string` | n/a | yes |
| ecs_cluster | The cluster ID where the ECS service will run | `string` | n/a | yes |
| vpc_id | The ID of the VPC where the ECS cluster is running | `string` | n/a | yes |
| vpc_subnets | The VPC subnets where the ECS task will run | `list(string)` | n/a | yes |
| task_exec_role | The IAM role which is assumed by the ECS tasks | `string` | n/a | yes |
| task_network_mode | The network mode for the ECS task | `string` | `awsvpc` | no |
| task_launch_type | The launch type for the ECS task. Choose between EC2 and FARGATE | `string` | `EC2` | no |
| task_cpu | The number of cpu units reserved for the container | `number` | `512` | no |
| task_memory | The hard limit (in MiB) of memory to present to the container | `number` | `512` | no |
| desired_count | The desired number of tasks to run | `number` | `1` | no |
| deployment_minimum_healthy_percent | The minimum percentage of running tasks to consider the serviec healthy | `number` | `50` | no |
| deployment_maximum_percent | The maximum number of tasks which can run during redeployment | `number` | `100` | no |
| environment | Environmental variables to pass to the container | `list(string)` | `[]` | no |
| security_groups | Additional security groups to assign to the ECS service | `list(string)` | `[]` | no |
| has_alb | Flag to determine if the service is associated with an ALB | `bool` | `false` | no |
| alb_port | The ALB port to be exposed for the service | `number` | 0 | no |
| alb_target_group | The ARN of the load balancer target group for the service | `string` | `null` | no |
| has_discovery | Flag to determine if the create service is associated with an autoscaling group of EC2 instances | `bool` | `false` | no |
| dns_namespace | The name of the DNS namespace to use as service discovery zone | `string` | `null` | no |
| has_asg | Flag to determine if the create service is associated with an autoscaling group of EC2 instances | `bool` | `false` | no |
| capacity_provider | The capacity provider name for the autoscaling group | `string` | `null` | no |
| has_logs | Flag to turn container log forwarding to CloudWatch (required an execution role which allows for CloudWatch logs group creation) | `bool` | `false` | no |
| logs_region | The region where the CloudWatch logs group for the service is created | `string` | `null` | no |


## Outputs

| Name | Description |
|------|-------------|
| service_arn | The full Amazon Resource Name (ARN) of the created service |
| task_family | The family of your task definition, used as the definition name |
| task_revision | The revision of the task in a particular family |
