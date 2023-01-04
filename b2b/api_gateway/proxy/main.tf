resource "aws_api_gateway_rest_api" "tenant" {
  name           = "api_${var.tenant}"
  description    = "API for ${var.tenant}"
  api_key_source = var.enable_usage_plan ? "AUTHORIZER" : "HEADER"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

resource "aws_api_gateway_stage" "tenant" {
  deployment_id = aws_api_gateway_deployment.tenant.id
  rest_api_id   = aws_api_gateway_rest_api.tenant.id
  stage_name    = var.stage_name
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

resource "aws_api_gateway_resource" "documents" {
  rest_api_id = aws_api_gateway_rest_api.tenant.id
  parent_id   = aws_api_gateway_rest_api.tenant.root_resource_id
  path_part   = "documents"
}

resource "aws_api_gateway_method" "documents" {
  rest_api_id      = aws_api_gateway_rest_api.tenant.id
  resource_id      = aws_api_gateway_resource.documents.id
  http_method      = "POST"
  authorization    = "CUSTOM"
  authorizer_id    = aws_api_gateway_authorizer.lambda_authorizer.id
  api_key_required = true
}

resource "aws_api_gateway_integration" "documents" {
  rest_api_id             = aws_api_gateway_rest_api.tenant.id
  resource_id             = aws_api_gateway_resource.documents.id
  http_method             = aws_api_gateway_method.documents.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  uri                     = "http://${var.nlb_dns_name}/documents"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = var.nlb_vpc_link_id
  request_parameters = {
    "integration.request.header.X-Tenant-Id" = "'${var.tenant}'"
  }
  timeout_milliseconds = 29000
}

resource "aws_api_gateway_deployment" "tenant" {
  depends_on  = [aws_api_gateway_method.proxy]
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
      var.enable_usage_plan,
      var.usage_plan_api_key_id,
      var.usage_plan_quota_settings,
      var.usage_plan_throttle_settings,
      aws_api_gateway_method.options_cors.id,
      aws_api_gateway_integration.options_cors.id
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
resource "aws_api_gateway_method" "options_cors" {
  rest_api_id        = aws_api_gateway_rest_api.tenant.id
  resource_id        = aws_api_gateway_resource.proxy.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.path.proxy" = true }
}

resource "aws_api_gateway_integration" "options_cors" {
  rest_api_id             = aws_api_gateway_rest_api.tenant.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.options_cors.http_method
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
}
