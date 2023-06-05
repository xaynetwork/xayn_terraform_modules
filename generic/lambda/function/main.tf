locals {
  environment_map = var.environment_variables == null ? [] : [var.environment_variables]
}

resource "aws_lambda_function" "this" {
  architectures    = [var.architecture]
  filename         = var.output_path
  function_name    = var.function_name
  role             = var.lambda_role_arn
  handler          = var.handler
  source_code_hash = var.source_code_hash
  runtime          = var.runtime
  timeout          = var.timeout

  dynamic "vpc_config" {
    for_each = var.vpc_subnet_ids != null && var.vpc_security_group_ids != null ? [true] : []
    content {
      security_group_ids = var.vpc_security_group_ids
      subnet_ids         = var.vpc_subnet_ids
    }
  }

  dynamic "environment" {
    for_each = local.environment_map
    content {
      variables = environment.value
    }
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
