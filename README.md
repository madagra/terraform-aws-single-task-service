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

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.5 |
| aws | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alb\_port | If load balanced service this is the application port for the target group | `number` | `0` | no |
| alb\_target\_group | If the service is associated with an application load balancer this is the ALB target group | `string` | `null` | no |
| capacity\_provider | The capacity provider name for the autoscaling group | `string` | `null` | no |
| container\_image | The Docker image to run with the task | `string` | n/a | yes |
| deployment\_maximum\_percent | The maximum number of tasks which can run during redeployment of the service | `number` | `100` | no |
| deployment\_minimum\_healthy\_percent | The minimum percentage of running tasks to consider the service healthy | `number` | `50` | no |
| desired\_count | The desired number of the ECS task to run | `number` | `1` | no |
| dns\_namespace | The Route53 DNS namespace where the ECS task is registered | `string` | `null` | no |
| ecs\_cluster | The ECS cluster ID where the service should run | `string` | n/a | yes |
| environment | The container environmental variables | `list(map(string))` | `[]` | no |
| has\_alb | Whether the service should be registered to an application load balancer | `bool` | `false` | no |
| has\_asg | Whether the service is associated with an autoscaling group of EC2 instances | `bool` | `false` | no |
| has\_discovery | Flag to switch on service discovery. If true, a valid DNS namespace must be provided | `bool` | `false` | no |
| has\_logs | Whether to forward logging to CloudWatch | `bool` | `false` | no |
| logs\_region | The region where the CloudWatch logs group is created | `string` | `null` | no |
| open\_ports | The ports which should be opened in the container and the security group to allow communication among services | `list(string)` | `[]` | no |
| security\_groups | Additional security groups to assign to the ECS service | `list(string)` | `[]` | no |
| task\_cpu | The CPU percentage allocated for the ECS task in vCPU units | `number` | `512` | no |
| task\_exec\_role | The IAM role which is assumed by the ECS tasks | `string` | n/a | yes |
| task\_launch\_type | The launch type for the ECS task. Choose between EC2 and FARGATE | `string` | `"EC2"` | no |
| task\_memory | The memory allocated for the ECS task in Mb | `number` | `512` | no |
| task\_name | The task name which gives the name to the ECS task, container and service discovery name | `string` | n/a | yes |
| task\_network\_mode | The network mode for the ECS task | `string` | `"awsvpc"` | no |
| vpc\_cidr | The trusted VPC CIDR to assign to the task security group ingress block | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| vpc\_id | The ID of the VPC where the ECS cluster is running | `string` | n/a | yes |
| vpc\_subnets | The VPC subnets where the application should run | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| service\_arn | The ARN of the ECS service created |
| task\_family | The family of your task definition, used as the definition name |
| task\_revision | The revision of the task in a particular family |
