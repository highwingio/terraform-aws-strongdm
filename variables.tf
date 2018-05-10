variable "ecs_cluster_arn" {
  type        = "string"
  description = "ARN of ECS cluster in which the service will be deployed"
}

variable "identifier" {
  description = "Unique identifier used to create service_identifier and task_identifier"
  default     = "sdm_relay"
}

variable "region" {
  type        = "string"
  description = "AWS region in which ECS cluster is located (default is 'us-east-1')"
  default     = "us-east-1"
}

variable "vpc_id" {
  type        = "string"
  description = "ID of VPC in which ECS cluster is located"
}
