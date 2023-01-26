resource "aws_iam_user" "this" {
  name = var.name
  path = var.path

  tags = var.tags
}

resource "aws_iam_user_policy" "this" {
  name   = var.policy_name
  user   = aws_iam_user.this.name
  policy = var.policy
}
