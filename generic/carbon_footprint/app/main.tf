# https://github.com/cloud-carbon-footprint/cloud-carbon-footprint/blob/trunk/cloudformation/ccf-app.yaml

data "aws_iam_policy_document" "s3" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
      "s3:PutObject"
    ]
    effect    = "Allow"
    resources = [var.billing_data_bucket, "${var.billing_data_bucket}/*"]
  }

  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
      "s3:PutObject"
    ]
    effect    = "Allow"
    resources = [var.athena_query_results_bucket, "${var.athena_query_results_bucket}/*"]
  }
}

data "aws_iam_policy_document" "athena" {
  statement {
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:GetWorkGroup",
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ce" {
  statement {
    actions   = ["ce:GetRightsizingRecommendation"]
    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "glue" {
  statement {
    actions   = ["glue:GetDatabase", "glue:GetTable", "glue:GetPartitions"]
    effect    = "Allow"
    resources = ["*"]
  }
}

# policies

resource "aws_iam_policy" "s3" {
  name   = "ccf-api-s3-policy"
  policy = data.aws_iam_policy_document.s3.json
}

resource "aws_iam_policy" "athena" {
  name   = "ccf-api-athena-policy"
  policy = data.aws_iam_policy_document.athena.json
}

resource "aws_iam_policy" "ce" {
  name   = "ccf-api-ce-policy"
  policy = data.aws_iam_policy_document.ce.json
}

resource "aws_iam_policy" "glue" {
  name   = "ccf-api-glue-policy"
  policy = data.aws_iam_policy_document.glue.json
}

# policy attachments

resource "aws_iam_role_policy_attachment" "s3" {
  policy_arn = aws_iam_policy.s3.arn
  role       = aws_iam_role.ccf_api_role.name
}

resource "aws_iam_role_policy_attachment" "athena" {
  policy_arn = aws_iam_policy.athena.arn
  role       = aws_iam_role.ccf_api_role.name
}

resource "aws_iam_role_policy_attachment" "ce" {
  policy_arn = aws_iam_policy.ce.arn
  role       = aws_iam_role.ccf_api_role.name
}

resource "aws_iam_role_policy_attachment" "glue" {
  policy_arn = aws_iam_policy.glue.arn
  role       = aws_iam_role.ccf_api_role.name
}

data "aws_iam_policy_document" "ccf_ecs_task_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.principals
    }
  }
}

# role
resource "aws_iam_role" "ccf_api_role" {
  assume_role_policy = data.aws_iam_policy_document.ccf_ecs_task_role.json
  name               = "ccf-app"
}
