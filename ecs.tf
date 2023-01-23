# ECS SERVICE

locals {
  container_name = "${var.service_identifier}-${var.task_identifier}"
  name_prefix    = substr("${local.container_name}-${var.vpc_id}", 0, 32)
}

resource "aws_lb" "nlb" {
  name               = local.name_prefix
  internal           = false #tfsec:ignore:AWS005
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = var.gateway_listen_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gateway.arn
  }
}

resource "aws_lb_target_group" "gateway" {
  name        = local.name_prefix
  port        = var.gateway_listen_port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "nlb_listener_traffic" {
  name_prefix = "sdm-nlb_listener-nlb"
  description = "Allow TCP traffic from NLB listener to SDM Gateway"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = var.gateway_listen_port
    to_port     = var.gateway_listen_port
    protocol    = "tcp"
    # This stays open because NLBs exist outside of security groups
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "task" {
  container_definitions = jsonencode([
    {
      name        = "${var.service_identifier}-${var.task_identifier}"
      image       = "quay.io/sdmrepo/relay"
      essential   = true
      environment = local.docker_environment
      secrets = [
        {
          name      = "SDM_RELAY_TOKEN",
          valueFrom = aws_ssm_parameter.gateway_token.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.task.name,
          "awslogs-region"        = data.aws_region.region.name,
          "awslogs-stream-prefix" = var.service_identifier
        }
      }
      portMappings = [
        {
          containerPort = var.gateway_listen_port,
          hostPort      = var.gateway_listen_port,
          protocol      = "tcp"
        }
      ]
    }
  ])
  cpu                      = 256
  execution_role_arn       = aws_iam_role.service.arn
  family                   = local.name_prefix
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task.arn
}

resource "aws_ecs_service" "service" {
  name                               = local.name_prefix
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
    subnets         = var.public_subnet_ids
    security_groups = concat([aws_security_group.nlb_listener_traffic.id], var.security_group_ids)
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.gateway.arn
    container_name   = local.container_name
    container_port   = var.gateway_listen_port
  }
}

resource "aws_cloudwatch_log_group" "task" {
  name              = local.name_prefix
  retention_in_days = var.ecs_log_retention
}
