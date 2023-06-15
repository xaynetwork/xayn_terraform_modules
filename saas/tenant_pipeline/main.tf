locals {
  function_name_pipeline = "tenant_pipeline"
  app_path               = "${path.module}/../control_app/src"
  pipeline_path          = "${local.app_path}/TenantPipeline"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "external" "build_tenent_pipeline" {
  program = ["bash", "-c", "${local.pipeline_path}/build.sh ${local.pipeline_path}"]
}

module "role_pipeline" {
  source = "../../generic/lambda/role"
  path   = "/saas/tenant_pipeline/"
  prefix = "AppSaasTenantPipeline"
  tags   = var.tags
}

resource "aws_iam_role_policy" "tenant_pipeline_dynamodb" {
  name   = "tenant-pipeline-dynamodb-policy"
  role   = module.role_pipeline.id
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
            "dynamodb:Update*",
            "dynamodb:PutItem",
            "dynamodb:Scan"
        ],
        "Resource": "${var.dynamodb_table_arn}"
    },
    {
            "Effect": "Allow",
            "Action": [
                "dynamodb:DescribeStream",
                "dynamodb:GetRecords",
                "dynamodb:GetShardIterator",
                "dynamodb:ListStreams"
            ],
            "Resource": "${var.dynamodb_table_arn}/stream/*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "cloudformation:*",
            "ssm:GetParameters",
            "apigateway:*"
        ],
        "Resource": "*"
    }
  ]
}
EOF
}

module "tenant_pipeline_function" {
  source = "../../generic/lambda/function"

  function_name         = local.function_name_pipeline
  handler               = "dist/handler.runPipelineHandler"
  runtime               = "nodejs18.x"
  timeout               = 900
  source_code_hash      = filebase64sha256(data.external.build_tenent_pipeline.result.output)
  output_path           = data.external.build_tenent_pipeline.result.output
  lambda_role_arn       = module.role_pipeline.arn
  log_retention_in_days = var.log_retention_in_days
  tags                  = var.tags

  environment_variables = {
    REGION         = data.aws_region.current.name
    DB_TABLE       = var.dynamodb_table_name
    API_ID         = var.apigateway_api_id
    API_STAGE_NAME = var.apigateway_api_stage_name
    ACCOUNT_ID     = data.aws_caller_identity.current.account_id
  }
}

resource "aws_lambda_event_source_mapping" "dynamodb_to_pipeline" {
  event_source_arn  = var.dynamodb_stream_arn
  function_name     = local.function_name_pipeline
  starting_position = "LATEST"
}
