variable "docker_image" {
  type        = string
  description = "Docker image to use"
  default     = "public.ecr.aws/highwing/strongdm:latest"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ARN of ECS cluster in which the service will be deployed"
}

variable "region" {
  type        = string
  description = "AWS region in which ECS cluster is located (default is 'us-east-1')"
  default     = "us-east-1"
}

variable "sdm_admin_token_parameter_arn" {
  type        = string
  description = "ARN of an SSM parameter holding a tokens to provide account access for fully automated strongDM use."
}

variable "vpc_id" {
  type        = string
  description = "ID of VPC in which ECS cluster is located"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs in which to place the ECS tasks"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs in which to place the load balancer"
}

variable "ecs_desired_count" {
  description = "Desired number of containers in the task (default 1)"
  default     = 1
}

variable "ecs_deployment_maximum_percent" {
  default     = "200"
  description = "Upper limit in percentage of tasks that can be running during a deployment (default 200)"
}

variable "ecs_deployment_minimum_healthy_percent" {
  default     = "100"
  description = "Lower limit in percentage of tasks that must remain healthy during a deployment (default 100)"
}

variable "ecs_health_check_grace_period" {
  default     = "0"
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 1800. (default 0)"
}

variable "docker_command" {
  description = "String to override CMD in Docker container (default \"\")"
  default     = ""
}

variable "service_identifier" {
  type        = string
  description = "Unique identifier for this service (used in log prefix, service name etc.)"
  default     = "sdm"
}

variable "task_identifier" {
  description = "Unique identifier for this task (used in log prefix, service name etc.)"
  default     = "gateway"
}

variable "log_group_name" {
  type        = string
  description = "Name for CloudWatch Log Group that will receive collector logs (must be unique, default is created from service_identifier and task_identifier)"
  default     = ""
}

variable "extra_task_policy_arns" {
  type        = list
  description = "List of ARNs of IAM policies to be attached to the ECS task role (in addition to the default policy, so cannot be more than 9 ARNs)"
  default     = []
}

variable "ecs_log_retention" {
  description = "Number of days of ECS task logs to retain (default 365)"
  default     = 365
}

variable "sdm_gateway_listen_app_port" {
  type        = string
  description = "Port for SDM gateway to listen on inside container"
  default     = "443"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Additional security groups for the SDM gateway (e.g. to access data sources)"
  default     = []
}
