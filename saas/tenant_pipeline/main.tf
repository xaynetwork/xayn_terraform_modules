locals {
  function_name_pipeline = "tenant_pipeline"
  app_path               = "${path.module}/../control_app/src"
  pipeline_path          = "${local.app_path}/TenantPipeline"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "external" "build_tenant_pipeline" {
  program = ["bash", "-c", "${local.pipeline_path}/build.sh ${local.pipeline_path}"]
}

module "tenant_pipeline_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "5.2.0"

  function_name                     = local.function_name_pipeline
  handler                           = "dist/handler.runPipelineHandler"
  runtime                           = "nodejs18.x"
  timeout                           = 900
  create_package                    = false
  local_existing_package            = data.external.build_tenant_pipeline.result.output
  cloudwatch_logs_retention_in_days = var.log_retention_in_days

  environment_variables = {
    REGION         = data.aws_region.current.name
    DB_TABLE       = var.dynamodb_table_name
    API_ID         = var.apigateway_api_id
    API_STAGE_NAME = var.apigateway_api_stage_name
    ACCOUNT_ID     = data.aws_caller_identity.current.account_id
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
            "dynamodb:Scan",
            "dynamodb:DeleteItem"
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
    EOT
  ]
  number_of_policy_jsons = 1

  event_source_mapping = {
    dynamodb = {
      event_source_arn  = var.dynamodb_stream_arn
      starting_position = "LATEST"
    }
  }

  tags = var.tags
}
