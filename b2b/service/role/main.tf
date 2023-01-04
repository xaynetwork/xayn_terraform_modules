data "aws_iam_policy_document" "assume_role_ecs_task" {
  statement {
    sid     = "${var.prefix}EcsTaskExecutionRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.prefix}EcsTaskExecutionRole"
  description        = var.description
  path               = var.path
  assume_role_policy = data.aws_iam_policy_document.assume_role_ecs_task.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
