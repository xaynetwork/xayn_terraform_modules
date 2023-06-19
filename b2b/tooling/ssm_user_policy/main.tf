data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

# Session user
# https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-restrict-access-quickstart.html#restrict-access-quickstart-end-user
data "aws_iam_policy_document" "user_port_forward_remote" {
  statement {
    sid     = "StartSession"
    actions = ["ssm:StartSession"]
    resources = [
      "arn:aws:ec2:${local.region}:${local.account_id}:instance/*",
      "arn:aws:ssm:${local.region}::document/AWS-StartPortForwardingSessionToRemoteHost"
    ]

    condition {
      test = "BoolIfExists"
      # https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-sessiondocumentaccesscheck.html
      # ensure that only the above document is allowed to be executed
      variable = "ssm:SessionDocumentAccessCheck"
      values   = ["true"]
    }
  }

  statement {
    sid = "DescribeEc2Instances"
    actions = [
      "ssm:DescribeSessions",
      "ssm:GetConnectionStatus",
      "ssm:DescribeInstanceProperties",
      "ec2:DescribeInstances"
    ]
    resources = ["*"]
  }

  statement {
    sid = "DescribeRdsClusters"
    actions = [
      "rds:DescribeDBClusters"
    ]
    resources = ["arn:aws:rds:*:*:cluster:*"]
  }

  statement {
    sid = "TerminateSession"
    actions = [
      "ssm:TerminateSession",
      "ssm:ResumeSession"
    ]
    resources = ["arn:aws:ssm:*:*:session/$${aws:username}-*"]
  }

  statement {
    sid = "AllowCloudWatchKeyUsage"
    actions = [
      "kms:GenerateDataKey"
    ]
    resources = [var.kms_key_arn]
  }
}

resource "aws_iam_policy" "session_manager_user" {
  name   = "${var.prefix}SessionManagerForUser"
  policy = data.aws_iam_policy_document.user_port_forward_remote.json
  tags   = var.tags
}
