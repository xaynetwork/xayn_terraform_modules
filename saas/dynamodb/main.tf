data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

locals {
  db_name = "saas_tenants"
}

module "dynamodb_table" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table?ref=v3.1.2"

  name = local.db_name

  ######
  # tenantId # email
  #   0001   | { auth-keys: [...],  name: "John Doe"}
  #   0002   | {...}    

  hash_key         = "id"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "KEYS_ONLY"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]

  tags = var.tags
}

resource "aws_iam_role" "this" {
  name               = "aws_backup_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.this.name
}

resource "aws_backup_plan" "this" {
  name = "Dynamodb_backup"

  rule {
    rule_name         = "daily_dynamodb_backup"
    target_vault_name = "Default"
    schedule          = var.backup_frecuency

    lifecycle {
      delete_after = var.retention_days
    }
  }
}

resource "aws_backup_selection" "this" {
  iam_role_arn = aws_iam_role.this.arn
  name         = "dynamodb_backup"
  plan_id      = aws_backup_plan.this.id

  resources = [
    module.dynamodb_table.dynamodb_table_arn
  ]
}
