data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [var.sns_arn]
  }
}

resource "aws_sns_topic_policy" "this" {
  arn    = var.sns_arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}
