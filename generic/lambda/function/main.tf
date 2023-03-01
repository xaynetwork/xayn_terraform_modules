data "external" "source_code_hash" {
  program = ["bash", "-c", "find .  -type f -print0 ! -name '*.zip'  | sort -z | xargs -0 shasum | shasum | head -c 40 | jq -R -c '{ hash: . }'"]
  working_dir = var.source_code_path
}

# This resource keeps track of the changed hash. It is used because aws_lambda_function.source_code_hash is internally
# comparing the hash of the zip file provided in output_path, which is problematic because zip files are changing
# when file last-modified attributes are changing. The resource external.source_code_hash calculates hashes 
# attribute agnostic.
resource "null_resource" "hash" {
  triggers = {
    hash = data.external.source_code_hash.result.hash
  }
}

resource "aws_lambda_function" "this" {
  architectures    = [var.architecture]
  filename         = var.output_path
  function_name    = var.function_name
  role             = var.lambda_role_arn

  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout

  publish = true

  dynamic "vpc_config" {
    for_each = var.vpc_subnet_ids != null && var.vpc_security_group_ids != null ? [true] : []
    content {
      security_group_ids = var.vpc_security_group_ids
      subnet_ids         = var.vpc_subnet_ids
    }
  }

  lifecycle {
    replace_triggered_by = [
      resource.null_resource.hash
    ]
  }

  tags = var.tags
}

# send lambda logs to CloudWatch
# Can also be created by the lambda with `logs:CreateLogGroup` but the group
# won't be delete after terraform destroy
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}
