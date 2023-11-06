data "aws_subnet" "this" {
  count = var.create_security_group ? 1 : 0
  id    = element(var.vpc_subnet_ids, 0)
}

resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name        = var.security_group_name
  description = var.security_group_description
  vpc_id      = data.aws_subnet.this[0].vpc_id

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

module "rag" {
  source                            = "terraform-aws-modules/lambda/aws"
  version                           = "~> 6.0"
  create                            = var.create
  description                       = var.description
  timeout                           = var.timeout
  source_path                       = "../src/"
  function_name                     = var.function_name
  handler                           = "app.lambda_handler"
  runtime                           = "python3.9"
  create_sam_metadata               = true
  publish                           = true
  memory_size                       = var.memory_size
  ephemeral_storage_size            = var.ephemeral_storage_size
  environment_variables             = var.environment_variables
  architectures                     = ["arm64"]
  reserved_concurrent_executions    = var.reserved_concurrent_executions
  provisioned_concurrent_executions = var.provisioned_concurrent_executions
  vpc_subnet_ids                    = var.vpc_subnet_ids
  vpc_security_group_ids            = flatten(concat([try(aws_security_group.this[0].id, [])], var.vpc_security_group_ids != null ? var.vpc_security_group_ids : []))
  cloudwatch_logs_retention_in_days = var.cloudwatch_logs_retention_in_days
  attach_cloudwatch_logs_policy     = var.attach_cloudwatch_logs_policy
  attach_network_policy             = var.attach_network_policy
  attach_policy_statements          = var.attach_policy_statements
  policy_statements                 = var.policy_statements
  tags                              = var.tags
  layers                            = var.layers
}
