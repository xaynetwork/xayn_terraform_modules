data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = "LambdaWithCloudWatchRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.prefix}LambdaWithCloudWatchRole"
  path               = var.path
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

# allow writing lambda logs to CloudWatch
resource "aws_iam_role_policy_attachment" "cw_access" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
