# ECS SERVICE

locals {
  docker_command_override = "${length(var.docker_command) > 0 ? "\"command\": [\"${var.docker_command}\"]," : ""}"
  name_prefix             = "${var.service_identifier}-${var.task_identifier}"
}

data "template_file" "container_definition" {
  template = file("${path.module}/files/container_definition.json")

  vars = {
    service_identifier    = var.service_identifier
    task_identifier       = var.task_identifier
    image                 = var.docker_image
    command_override      = local.docker_command_override
    environment           = jsonencode(local.docker_environment)
    awslogs_region        = data.aws_region.region.name
    awslogs_group         = local.name_prefix
    awslogs_stream_prefix = var.service_identifier
    app_port              = var.sdm_gateway_listen_app_port
  }
}

resource "aws_lb" "nlb" {
  name_prefix        = local.name_prefix
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = var.sdm_gateway_listen_app_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gateway.arn
  }
}

resource "aws_lb_target_group" "gateway" {
  name_prefix = local.name_prefix
  port        = var.sdm_gateway_listen_app_port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "inbound_nlb_traffic" {
  name_prefix = "sdm-inbound-nlb"
  description = "Allow TCP inbound traffic from SDM NLB"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = var.sdm_gateway_listen_app_port
    to_port     = var.sdm_gateway_listen_app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "task" {
  container_definitions    = data.template_file.container_definition.rendered
  cpu                      = 256
  execution_role_arn       = aws_iam_role.service.arn
  family                   = local.name_prefix
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task.arn
}

resource "aws_ecs_service" "service" {
  name_prefix                        = "${local.name_prefix}-service"
  cluster                            = var.ecs_cluster_arn
  task_definition                    = aws_ecs_task_definition.task.arn
  desired_count                      = var.ecs_desired_count
  deployment_maximum_percent         = var.ecs_deployment_maximum_percent
  deployment_minimum_healthy_percent = var.ecs_deployment_minimum_healthy_percent
  health_check_grace_period_seconds  = var.ecs_health_check_grace_period

  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = concat([aws_security_group.inbound_nlb_traffic.id], var.security_group_ids)
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.gateway.arn
    container_name   = local.name_prefix
    container_port   = var.sdm_gateway_listen_app_port
  }
}

resource "aws_cloudwatch_log_group" "task" {
  name_prefix       = local.name_prefix
  retention_in_days = var.ecs_log_retention
}
