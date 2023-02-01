# allow API Gateway to call the lambda authorizer
data "aws_iam_policy_document" "assume_role_api_gateway" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "authorizer_invocation" {
  statement {
    effect  = "Allow"
    actions = ["lambda:InvokeFunction"]
    resources = [
      var.lambda_authorizer_arn,
    ]
  }
}

resource "aws_iam_role" "authorizer_invocation" {
  name               = "api_gateway_authorizer_invocation_${var.tenant}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_api_gateway.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "authorizer_invocation" {
  name   = "authorizer_invocation_${var.tenant}"
  role   = aws_iam_role.authorizer_invocation.id
  policy = data.aws_iam_policy_document.authorizer_invocation.json
}
