data "aws_iam_policy_document" "ssm_secrets" {
  statement {
    sid       = "${var.prefix}SSMParameterAccess"
    effect    = "Allow"
    actions   = ["ssm:GetParameters"]
    resources = var.ssm_parameter_arns
  }
}

resource "aws_iam_policy" "ssm_secrets" {
  name        = "${var.prefix}EcsTaskExecutionRoleSSMSecretsPolicy"
  description = var.description
  path        = var.path
  policy      = data.aws_iam_policy_document.ssm_secrets.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_secrets" {
  role       = var.role_name
  policy_arn = aws_iam_policy.ssm_secrets.arn
}
