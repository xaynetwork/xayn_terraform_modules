data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_iam_policy_document" "assume_role_ecs_task" {
  statement {
    sid     = "EcsTaskRoleCloudWatchPutMetrics"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "EcsTaskRoleCloudWatchPutMetrics"
  description        = "ElasticSearch to CloudWatch metric exporter task role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ecs_task.json
  tags               = var.tags
}

data "aws_iam_policy_document" "cw_put_metrics" {
  statement {
    sid       = "CloudWatchPutMetricsAccess"
    effect    = "Allow"
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cw_put_metrics" {
  name        = "EcsTaskRoleCloudWatchPutMetricsPolicy"
  description = "ElasticSearch to CloudWatch metric exporter task policy"
  policy      = data.aws_iam_policy_document.cw_put_metrics.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "cw_put_metrics" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.cw_put_metrics.arn
}
