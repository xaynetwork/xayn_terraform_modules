data "aws_iam_policy_document" "role_access_policy" {

  statement {
    sid = "GetAuthToken"

    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage"
    ]

    effect    = "Allow"
    resources = var.ecr_arns
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.role_access_policy.json
}

module "iam" {
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-github-oidc-role?ref=v5.8.0"

  name     = var.role_name
  subjects = var.repositories
  policies = {
    ECRAccess = aws_iam_policy.iam_policy.arn
  }
  tags = var.tags

}
