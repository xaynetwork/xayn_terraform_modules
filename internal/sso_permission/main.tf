data "aws_ssoadmin_instances" "this" {}

locals {
  sso_instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]
}

resource "aws_ssoadmin_permission_set" "this" {
  name             = var.permission_name
  description      = "Permission set for ${var.permission_name}"
  instance_arn     = local.sso_instance_arn
  session_duration = var.duration
  tags             = var.tags
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "this" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
  customer_managed_policy_reference {
    name = var.permission_name
  }
}

data "aws_iam_policy_document" "policy_document" {
  statement {
    actions   = var.actions
    resources = var.resources
    effect = "Allow"
  }
}

resource "aws_iam_policy" "this" {
  name   = "${var.permission_name}-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.policy_document.json
  tags   = var.tags
}
