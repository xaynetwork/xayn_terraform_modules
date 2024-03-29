data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  api_name   = "api_${var.tenant}"
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name
}

resource "aws_api_gateway_rest_api" "tenant" {
  name           = local.api_name
  description    = "API for ${var.tenant}"
  api_key_source = var.enable_usage_plan ? "AUTHORIZER" : "HEADER"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "access_logs" {
  count             = var.enable_access_logs ? 1 : 0
  name              = "API-Gateway-Access-Logs_${aws_api_gateway_rest_api.tenant.id}/${var.stage_name}"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

resource "aws_api_gateway_stage" "tenant" {
  deployment_id = aws_api_gateway_deployment.tenant.id
  rest_api_id   = aws_api_gateway_rest_api.tenant.id
  stage_name    = var.stage_name

  dynamic "access_log_settings" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.access_logs[0].arn
      format          = jsonencode(var.access_logs_format)
    }
  }
}

resource "aws_api_gateway_authorizer" "lambda_authorizer" {
  name                             = "api-key-authorizer"
  identity_source                  = "method.request.header.${var.token_name}"
  rest_api_id                      = aws_api_gateway_rest_api.tenant.id
  authorizer_uri                   = var.lambda_authorizer_invoke_arn
  authorizer_credentials           = aws_iam_role.authorizer_invocation.arn
  authorizer_result_ttl_in_seconds = 300
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.tenant.id
  parent_id   = aws_api_gateway_rest_api.tenant.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id        = aws_api_gateway_rest_api.tenant.id
  resource_id        = aws_api_gateway_resource.proxy.id
  http_method        = "ANY"
  authorization      = "CUSTOM"
  authorizer_id      = aws_api_gateway_authorizer.lambda_authorizer.id
  request_parameters = { "method.request.path.proxy" = true }
  api_key_required   = true
}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id             = aws_api_gateway_rest_api.tenant.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${var.nlb_dns_name}/{proxy}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = var.nlb_vpc_link_id
  request_parameters = {
    "integration.request.path.proxy" : "method.request.path.proxy"
    "integration.request.header.X-Tenant-Id" = "'${var.tenant}'"
  }
  timeout_milliseconds = 8000
}

#########
## Exceptions mainly for timeouts
#########

resource "aws_api_gateway_resource" "documents" {
  rest_api_id = aws_api_gateway_rest_api.tenant.id
  parent_id   = aws_api_gateway_rest_api.tenant.root_resource_id
  path_part   = "documents"
}

resource "aws_api_gateway_method" "documents" {
  rest_api_id        = aws_api_gateway_rest_api.tenant.id
  resource_id        = aws_api_gateway_resource.documents.id
  http_method        = "ANY"
  authorization      = "CUSTOM"
  authorizer_id      = aws_api_gateway_authorizer.lambda_authorizer.id
  request_parameters = { "method.request.path.proxy" = true }
  api_key_required   = true
}

resource "aws_api_gateway_integration" "documents" {
  rest_api_id             = aws_api_gateway_rest_api.tenant.id
  resource_id             = aws_api_gateway_resource.documents.id
  http_method             = aws_api_gateway_method.documents.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${var.nlb_dns_name}/documents"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = var.nlb_vpc_link_id
  request_parameters = {
    "integration.request.header.X-Tenant-Id" = "'${var.tenant}'"
  }
  timeout_milliseconds = 29000
}

resource "aws_api_gateway_resource" "documents_proxy" {
  rest_api_id = aws_api_gateway_rest_api.tenant.id
  parent_id   = aws_api_gateway_resource.documents.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "documents_proxy" {
  rest_api_id        = aws_api_gateway_rest_api.tenant.id
  resource_id        = aws_api_gateway_resource.documents_proxy.id
  http_method        = "ANY"
  authorization      = "CUSTOM"
  authorizer_id      = aws_api_gateway_authorizer.lambda_authorizer.id
  request_parameters = { "method.request.path.proxy" = true }
  api_key_required   = true
}

resource "aws_api_gateway_integration" "documents_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.tenant.id
  resource_id             = aws_api_gateway_resource.documents_proxy.id
  http_method             = aws_api_gateway_method.documents_proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${var.nlb_dns_name}/documents/{proxy}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = var.nlb_vpc_link_id
  request_parameters = {
    "integration.request.path.proxy" : "method.request.path.proxy"
    "integration.request.header.X-Tenant-Id" = "'${var.tenant}'"
  }
  timeout_milliseconds = 29000
}

resource "aws_api_gateway_resource" "candidates" {
  rest_api_id = aws_api_gateway_rest_api.tenant.id
  parent_id   = aws_api_gateway_rest_api.tenant.root_resource_id
  path_part   = "candidates"
}

resource "aws_api_gateway_method" "candidates" {
  rest_api_id      = aws_api_gateway_rest_api.tenant.id
  resource_id      = aws_api_gateway_resource.candidates.id
  http_method      = "PUT"
  authorization    = "CUSTOM"
  authorizer_id    = aws_api_gateway_authorizer.lambda_authorizer.id
  api_key_required = true
}

resource "aws_api_gateway_integration" "candidates" {
  rest_api_id             = aws_api_gateway_rest_api.tenant.id
  resource_id             = aws_api_gateway_resource.candidates.id
  http_method             = aws_api_gateway_method.candidates.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "PUT"
  uri                     = "http://${var.nlb_dns_name}/candidates"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = var.nlb_vpc_link_id
  request_parameters = {
    "integration.request.header.X-Tenant-Id" = "'${var.tenant}'"
  }
  timeout_milliseconds = 29000
}

#########

resource "aws_api_gateway_deployment" "tenant" {
  rest_api_id = aws_api_gateway_rest_api.tenant.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_authorizer.lambda_authorizer.id,
      aws_api_gateway_resource.proxy.id,
      aws_api_gateway_method.proxy.id,
      aws_api_gateway_integration.proxy.id,
      aws_api_gateway_resource.documents.id,
      aws_api_gateway_method.documents.id,
      aws_api_gateway_integration.documents.id,
      aws_api_gateway_integration.documents.request_parameters,
      aws_api_gateway_resource.documents_proxy.id,
      aws_api_gateway_method.documents_proxy.id,
      aws_api_gateway_integration.documents_proxy.id,
      aws_api_gateway_integration.documents_proxy.request_parameters,
      aws_api_gateway_resource.candidates.id,
      aws_api_gateway_method.candidates.id,
      aws_api_gateway_integration.candidates.id,
      aws_api_gateway_integration.candidates.request_parameters,
      var.enable_usage_plan,
      var.usage_plan_api_key_id,
      var.usage_plan_quota_settings,
      var.usage_plan_throttle_settings,
      aws_api_gateway_method.options_cors_proxy.id,
      aws_api_gateway_integration.options_cors_proxy.id,
      aws_api_gateway_method.options_cors_documents.id,
      aws_api_gateway_integration.options_cors_documents.id,
      aws_api_gateway_method.options_cors_documents_proxy.id,
      aws_api_gateway_integration.options_cors_documents_proxy.id,
      try(aws_api_gateway_resource.rag[0].id, ""),
      try(aws_api_gateway_method.rag[0].id, ""),
      try(aws_api_gateway_integration.rag[0].id, ""),
      try(aws_api_gateway_method.rag_options[0].id, ""),
      try(aws_api_gateway_integration.rag_options[0].id, "")
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "stage" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.tenant.id}/${aws_api_gateway_stage.tenant.stage_name}"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

resource "aws_api_gateway_method_settings" "tenant" {
  rest_api_id = aws_api_gateway_rest_api.tenant.id
  stage_name  = aws_api_gateway_stage.tenant.stage_name

  method_path = "*/*"
  settings {
    logging_level          = "INFO"
    throttling_burst_limit = var.default_method_throttle_settings != null ? var.default_method_throttle_settings.burst_limit : var.usage_plan_throttle_settings.burst_limit * 3
    throttling_rate_limit  = var.default_method_throttle_settings != null ? var.default_method_throttle_settings.rate_limit : var.usage_plan_throttle_settings.rate_limit * 3
    metrics_enabled        = var.metrics_enabled_api
  }

  depends_on = [
    aws_cloudwatch_log_group.stage
  ]
}

# usage plan
resource "aws_api_gateway_usage_plan" "tenant" {
  count = var.enable_usage_plan ? 1 : 0
  name  = "Usage plan of ${var.tenant}"

  api_stages {
    api_id = aws_api_gateway_rest_api.tenant.id
    stage  = aws_api_gateway_stage.tenant.stage_name
  }

  dynamic "quota_settings" {
    for_each = var.usage_plan_quota_settings != null ? [1] : []
    content {
      limit  = var.usage_plan_quota_settings.limit
      offset = var.usage_plan_quota_settings.offset
      period = var.usage_plan_quota_settings.period
    }
  }

  throttle_settings {
    burst_limit = var.usage_plan_throttle_settings.burst_limit
    rate_limit  = var.usage_plan_throttle_settings.rate_limit
  }

  tags = var.tags
}

resource "aws_api_gateway_usage_plan_key" "api_key" {
  count         = var.enable_usage_plan ? 1 : 0
  key_id        = var.usage_plan_api_key_id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.tenant[0].id
}

# cors:
# don't require authentication for OPTIONS (preflight) requests. The requests
# are performed by the browser therefore it can't contain our api token
# the request is handled by the backend
resource "aws_api_gateway_method" "options_cors_proxy" {
  rest_api_id        = aws_api_gateway_rest_api.tenant.id
  resource_id        = aws_api_gateway_resource.proxy.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.path.proxy" = true }
}

resource "aws_api_gateway_integration" "options_cors_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.tenant.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.options_cors_proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${var.nlb_dns_name}/{proxy}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = var.nlb_vpc_link_id
  request_parameters = {
    "integration.request.path.proxy" : "method.request.path.proxy",
    "integration.request.header.X-Tenant-Id" = "'${var.tenant}'"
  }
}

resource "aws_api_gateway_method" "options_cors_documents" {
  rest_api_id   = aws_api_gateway_rest_api.tenant.id
  resource_id   = aws_api_gateway_resource.documents.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_cors_documents" {
  rest_api_id             = aws_api_gateway_rest_api.tenant.id
  resource_id             = aws_api_gateway_resource.documents.id
  http_method             = aws_api_gateway_method.options_cors_documents.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${var.nlb_dns_name}/documents"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = var.nlb_vpc_link_id
}

resource "aws_api_gateway_method" "options_cors_documents_proxy" {
  rest_api_id        = aws_api_gateway_rest_api.tenant.id
  resource_id        = aws_api_gateway_resource.documents_proxy.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.path.proxy" = true }
}

resource "aws_api_gateway_integration" "options_cors_documents_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.tenant.id
  resource_id             = aws_api_gateway_resource.documents_proxy.id
  http_method             = aws_api_gateway_method.options_cors_documents_proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${var.nlb_dns_name}/documents/{proxy}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = var.nlb_vpc_link_id
  request_parameters = {
    "integration.request.path.proxy" : "method.request.path.proxy",
    "integration.request.header.X-Tenant-Id" = "'${var.tenant}'"
  }
}

# rag endpoint
resource "aws_api_gateway_resource" "rag" {
  count       = var.enable_rag_endpoint ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.tenant.id
  parent_id   = aws_api_gateway_rest_api.tenant.root_resource_id
  path_part   = "rag"
}

resource "aws_api_gateway_method" "rag" {
  count            = var.enable_rag_endpoint ? 1 : 0
  rest_api_id      = aws_api_gateway_rest_api.tenant.id
  resource_id      = aws_api_gateway_resource.rag[0].id
  http_method      = "POST"
  authorization    = "CUSTOM"
  authorizer_id    = aws_api_gateway_authorizer.lambda_authorizer.id
  api_key_required = true
}

resource "aws_api_gateway_integration" "rag" {
  count                   = var.enable_rag_endpoint ? 1 : 0
  rest_api_id             = aws_api_gateway_rest_api.tenant.id
  resource_id             = aws_api_gateway_resource.rag[0].id
  http_method             = aws_api_gateway_method.rag[0].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.rag_integration_config.invoke_arn
}

resource "aws_lambda_permission" "rag" {
  count         = var.enable_rag_endpoint ? 1 : 0
  statement_id  = "AllowPOSTExecutionFromAPIGatewayFor${var.tenant}"
  action        = "lambda:InvokeFunction"
  function_name = var.rag_integration_config.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:${local.partition}:execute-api:${local.region}:${local.account_id}:${aws_api_gateway_rest_api.tenant.id}/*/${aws_api_gateway_method.rag[0].http_method}${aws_api_gateway_resource.rag[0].path}"
}

# CORS
resource "aws_api_gateway_method" "rag_options" {
  count         = var.enable_rag_endpoint ? 1 : 0
  rest_api_id   = aws_api_gateway_rest_api.tenant.id
  resource_id   = aws_api_gateway_resource.rag[0].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "rag_options" {
  count                   = var.enable_rag_endpoint ? 1 : 0
  rest_api_id             = aws_api_gateway_rest_api.tenant.id
  resource_id             = aws_api_gateway_resource.rag[0].id
  http_method             = aws_api_gateway_method.rag_options[0].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.rag_integration_config.invoke_arn
}

resource "aws_lambda_permission" "rag_options" {
  count         = var.enable_rag_endpoint ? 1 : 0
  statement_id  = "AllowOPTIONSExecutionFromAPIGatewayFor${var.tenant}"
  action        = "lambda:InvokeFunction"
  function_name = var.rag_integration_config.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:${local.partition}:execute-api:${local.region}:${local.account_id}:${aws_api_gateway_rest_api.tenant.id}/*/${aws_api_gateway_method.rag_options[0].http_method}${aws_api_gateway_resource.rag[0].path}"
}

resource "aws_api_gateway_method_settings" "rag" {
  count       = var.enable_rag_endpoint ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.tenant.id
  stage_name  = aws_api_gateway_stage.tenant.stage_name

  method_path = "${aws_api_gateway_resource.rag[0].path}/${aws_api_gateway_method.rag[0].http_method}"
  settings {
    logging_level          = "INFO"
    throttling_burst_limit = var.rag_integration_config.throttling.burst_limit
    throttling_rate_limit  = var.rag_integration_config.throttling.rate_limit
    metrics_enabled        = var.metrics_enabled_api
  }

  depends_on = [
    aws_cloudwatch_log_group.stage
  ]
}

# aws waf
resource "aws_wafv2_web_acl_association" "api_gateway" {
  count        = var.web_acl_arn != null ? 1 : 0
  resource_arn = aws_api_gateway_stage.tenant.arn
  web_acl_arn  = var.web_acl_arn
}

# CloudWatch alarms
module "alarms" {
  providers = {
    aws = aws.monitoring-account
  }
  source = "../../../generic/alarms/api_gateway"

  account_id = data.aws_caller_identity.current.account_id
  prefix     = "${data.aws_caller_identity.current.account_id}_"

  api_name  = local.api_name
  api_stage = aws_api_gateway_stage.tenant.stage_name

  http_5xx_error    = var.alarm_http_5xx_error
  latency           = var.alarm_latency
  error_rate        = var.alarm_error_rate
  latency_by_method = var.alarm_latency_by_method

  tags = var.tags
}
