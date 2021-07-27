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
  name_prefix        = "${var.service_identifier}-${var.task_identifier}-ecsTaskRole"
  path               = "/${var.service_identifier}/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_task.json
}

resource "aws_iam_role" "service" {
  name_prefix        = "${var.service_identifier}-${var.task_identifier}-ecsServiceRole"
  path               = "/${var.service_identifier}/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_service.json
}

resource "aws_iam_role_policy_attachment" "service" {
  role       = aws_iam_role.service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "task_extra" {
  count      = length(var.extra_task_policy_arns)
  role       = aws_iam_role.task.name
  policy_arn = var.extra_task_policy_arns[count.index]
}
