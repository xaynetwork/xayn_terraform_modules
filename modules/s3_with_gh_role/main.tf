data "aws_iam_policy_document" "s3_role_access_policy" {
  statement {
    sid    = "ApplicationObjectAccess"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
    ]
    resources = [
      module.s3.s3_bucket_arn,
    ]
  }
}

resource "aws_iam_policy" "s3_iam_policy" {
  name   = "s3_iam_policy"
  policy = data.aws_iam_policy_document.s3_role_access_policy.json
}

module "s3" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket?ref=v3.6.0"

  bucket                           = var.name
  acl                              = var.acl
  versioning                       = var.versioning
  block_public_acls                = true
  block_public_policy              = true
  ignore_public_acls               = true
  restrict_public_buckets          = true
  attach_require_latest_tls_policy = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "aws:kms"
      }
    }
  }

  tags = var.tags
}

module "iam" {
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-github-oidc-role?ref=v5.8.0"

  name     = "${var.name}-role"
  subjects = var.repositories
  policies = {
    S3Access = aws_iam_policy.s3_iam_policy.arn
  }
  tags = var.tags
}

resource "null_resource" "prevent_destroy" {
  depends_on = [
    module.s3
  ]

  triggers = {
    bucket_id = module.s3.s3_bucket_id
  }

  lifecycle {
    prevent_destroy = true
  }
}
