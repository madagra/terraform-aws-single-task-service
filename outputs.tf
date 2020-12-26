output "service_arn" {
  description = "The ARN of the ECS service created"
  value       = aws_ecs_service.service.id
}

output "task_family" {
  description = "The family of your task definition, used as the definition name"
  value       = module.task_definition.family
}

output "task_revision" {
  description = "The revision of the task in a particular family"
  value       = module.task_definition.revision
}