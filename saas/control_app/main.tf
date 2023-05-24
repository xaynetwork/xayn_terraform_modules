locals {
  function_name         = "authenticator"
  app_path              = "${path.module}/src"
  function_path         = "${local.app_path}/app"
  function_build_path   = "${path.module}/build"
  function_zip_filename = "${local.function_name}.zip"
  dest_dir_name         = "app"
  output_path           = "${local.function_build_path}/${local.function_zip_filename}"
}

data "aws_region" "current" {}

# ### needs to have installed
# ### https://github.com/timo-reymann/deterministic-zip
# ### https://www.reddit.com/r/Terraform/comments/aupudn/building_deterministic_zips_to_minimize_lambda/
data "external" "build" {
  program = ["bash", "-c", "${local.app_path}/build.sh \"${local.function_path}\" \"${local.function_build_path}\" \"${local.dest_dir_name}\" \"${local.function_zip_filename}\" Function &> /tmp/temp.log && echo '{ \"output\": \"${local.output_path}\" }'"]
}

module "role" {
  source = "../../generic/lambda/role"
  path   = "/saas/"
  prefix = "AppSaas"
  tags   = var.tags
}

resource "aws_iam_role_policy" "authenticator_dynamodb" {
  name   = "authenticator-dynamodb-policy"
  role   = module.role.id
  policy = <<EOF
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
EOF
}

module "authentication_function" {
  source = "../../generic/lambda/function"

  function_name         = local.function_name
  handler               = "app.functions.authenticator.lambda_handler"
  runtime               = "python3.9"
  source_code_hash      = filebase64sha256(data.external.build.result.output)
  output_path           = local.output_path
  lambda_role_arn       = module.role.arn
  log_retention_in_days = var.log_retention_in_days
  tags                  = var.tags

  environment_variables = {
      REGION = data.aws_region.current.name
      DB_TABLE  = var.dynamodb_table_name 
  }
}