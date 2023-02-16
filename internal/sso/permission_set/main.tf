data "aws_ssoadmin_instances" "this" {}

locals {
  sso_instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]
}

resource "aws_ssoadmin_permission_set" "this" {
  name             = var.permission_name
  description      = var.permission_description
  instance_arn     = local.sso_instance_arn
  session_duration = var.duration
  tags             = var.tags
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  count              = length(var.managed_policies_arns) > 0 ? length(var.managed_policies_arns) : 0
  instance_arn       = local.sso_instance_arn
  managed_policy_arn = var.managed_policies_arns[count.index]
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "this" {
  count              = var.policy_name != null ? 1 : 0
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
  customer_managed_policy_reference {
    name = var.policy_name
  }
}

#Creating Policy
data "aws_iam_policy_document" "policy_document" {
  count = var.policy_conf != null ? 1 : 0
  dynamic "statement" {
    for_each = var.policy_conf
    content {
      actions   = statement.value.actions
      resources = statement.value.resources
      effect    = "Allow"
    }
  }
}

resource "aws_iam_policy" "this" {
  count  = var.policy_conf != null ? 1 : 0
  path   = "/"
  name   = var.policy_name
  policy = data.aws_iam_policy_document.policy_document[count.index].json
  tags   = var.tags
}
