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

# aws managed policy
resource "aws_ssoadmin_managed_policy_attachment" "this" {
  count              = length(var.managed_policies_arns) > 0 ? length(var.managed_policies_arns) : 0
  instance_arn       = local.sso_instance_arn
  managed_policy_arn = var.managed_policies_arns[count.index]
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
}

# customer managed policy
resource "aws_ssoadmin_customer_managed_policy_attachment" "this" {
  count              = length(var.customer_managed_policy_references) > 0 ? length(var.customer_managed_policy_references) : 0
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn

  customer_managed_policy_reference {
    name = var.customer_managed_policy_references[count.index].name
    path = var.customer_managed_policy_references[count.index].path
  }
}

# inline policy
data "aws_iam_policy_document" "inline" {
  count = length(var.inline_policy_statements) > 0 ? 1 : 0

  dynamic "statement" {
    for_each = var.inline_policy_statements
    content {
      actions   = statement.value.actions
      resources = statement.value.resources
      effect    = "Allow"
    }
  }
}

resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  count              = length(var.inline_policy_statements) > 0 ? 1 : 0
  inline_policy      = data.aws_iam_policy_document.inline[0].json
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
}
