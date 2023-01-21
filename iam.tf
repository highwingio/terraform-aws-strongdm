data "aws_iam_policy_document" "task_policy" {
  statement {
    actions = [
      "ec2:Describe*",
      "autoscaling:Describe*",
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "cloudwatch:GetMetricStatistics",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:PutLogEvents",
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "service_policy" {
  statement {
    actions   = ["ssm:GetParameters"]
    resources = [aws_ssm_parameter.gateway_token.arn]
  }
}

data "aws_iam_policy_document" "assume_role_task" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_service" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task" {
  name_prefix        = "${var.service_identifier}-${var.task_identifier}-task"
  path               = "/${var.service_identifier}/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_task.json
}

resource "aws_iam_role" "service" {
  name_prefix        = "${var.service_identifier}-${var.task_identifier}-service"
  path               = "/${var.service_identifier}/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_service.json
}

resource "aws_iam_role_policy_attachment" "service" {
  role       = aws_iam_role.service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "service" {
  name_prefix = "${var.service_identifier}-${var.task_identifier}-ecsServicePolicy"
  role        = aws_iam_role.service.id
  policy      = data.aws_iam_policy_document.service_policy.json
}

resource "aws_iam_role_policy_attachment" "task_extra" {
  count      = length(var.extra_task_policy_arns)
  role       = aws_iam_role.task.name
  policy_arn = var.extra_task_policy_arns[count.index]
}
