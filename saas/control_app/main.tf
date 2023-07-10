locals {
  app_path              = "${path.module}/src"
  function_path         = "${local.app_path}/TenantManagement"
  function_build_path   = "${path.module}/build"
  function_zip_filename = "TenantManagement.zip"
  dest_dir_name         = "TenantManagement"
  output_path           = "${local.function_build_path}/${local.function_zip_filename}"
}

data "aws_region" "current" {}

data "external" "build" {
  program = ["bash", "-c", "${local.app_path}/build.sh \"${local.function_path}\" \"${local.function_build_path}\" \"${local.dest_dir_name}\" \"${local.function_zip_filename}\" Function &> /tmp/temp.log && echo '{ \"output\": \"${local.output_path}\" }'"]
}

module "authentication_function" {
  depends_on = [data.external.build]
  source     = "terraform-aws-modules/lambda/aws"
  version    = "5.2.0"

  function_name                     = "authenticator"
  handler                           = "TenantManagement.functions.authenticator.lambda_handler"
  runtime                           = "python3.10"
  create_package                    = false
  local_existing_package            = local.output_path
  cloudwatch_logs_retention_in_days = var.log_retention_in_days

  environment_variables = {
    REGION   = data.aws_region.current.name
    DB_TABLE = var.dynamodb_table_name
  }

  attach_policy_jsons = true
  policy_jsons = [
    <<-EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "dynamodb:List*",
            "dynamodb:DescribeReservedCapacity*",
            "dynamodb:DescribeLimits",
            "dynamodb:DescribeTimeToLive"
        ],
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "dynamodb:BatchGet*",
            "dynamodb:DescribeStream",
            "dynamodb:DescribeTable",
            "dynamodb:Get*",
            "dynamodb:Query",
            "dynamodb:Scan"
        ],
        "Resource": "${var.dynamodb_table_arn}"
    }
  ]
}
    EOT
  ]
  number_of_policy_jsons = 1

  tags = var.tags
}


module "provisioning_function" {
  depends_on = [data.external.build]
  source     = "terraform-aws-modules/lambda/aws"
  version    = "5.2.0"

  function_name                     = "provisioning"
  handler                           = "TenantManagement.functions.provisioning.lambda_handler"
  runtime                           = "python3.10"
  timeout                           = 60
  create_package                    = false
  local_existing_package            = local.output_path
  cloudwatch_logs_retention_in_days = var.log_retention_in_days

  environment_variables = {
    REGION   = data.aws_region.current.name
    DB_TABLE = var.dynamodb_table_name
  }

  attach_policy_jsons = true
  policy_jsons = [
    <<-EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "dynamodb:List*",
            "dynamodb:DescribeReservedCapacity*",
            "dynamodb:DescribeLimits",
            "dynamodb:DescribeTimeToLive"
        ],
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "dynamodb:BatchGet*",
            "dynamodb:DescribeStream",
            "dynamodb:DescribeTable",
            "dynamodb:Get*",
            "dynamodb:Query",
            "dynamodb:Update*",
            "dynamodb:PutItem",
            "dynamodb:Scan"
        ],
        "Resource": "${var.dynamodb_table_arn}"
    }
  ]
}
    EOT
  ]
  number_of_policy_jsons = 1

  tags = var.tags
}
