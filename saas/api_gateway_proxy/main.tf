resource "aws_api_gateway_rest_api" "api" {
  name           = var.name
  description    = "API for ${var.name}"
  api_key_source = "AUTHORIZER"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "access_logs" {
  count             = var.enable_access_logs ? 1 : 0
  name              = "API-Gateway-Access-Logs_${aws_api_gateway_rest_api.api.id}/${var.stage_name}"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

resource "aws_api_gateway_stage" "api" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
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
  rest_api_id                      = aws_api_gateway_rest_api.api.id
  authorizer_uri                   = var.lambda_authorizer_invoke_arn
  authorizer_credentials           = aws_iam_role.authorizer_invocation.arn
  authorizer_result_ttl_in_seconds = 300
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.proxy.id
  http_method        = "ANY"
  authorization      = "CUSTOM"
  authorizer_id      = aws_api_gateway_authorizer.lambda_authorizer.id
  request_parameters = { "method.request.path.proxy" = true }
  api_key_required   = true
}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${var.nlb_dns_name}/{proxy}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = var.nlb_vpc_link_id
  request_parameters = merge({
    "integration.request.path.proxy" : "method.request.path.proxy",
  }, var.request_parameters)
  timeout_milliseconds = 8000
}

#########
## Exceptions mainly for timeouts
#########

resource "aws_api_gateway_resource" "documents" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "documents"
}

resource "aws_api_gateway_method" "documents" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.documents.id
  http_method      = "ANY"
  authorization    = "CUSTOM"
  authorizer_id    = aws_api_gateway_authorizer.lambda_authorizer.id
  api_key_required = true
}

resource "aws_api_gateway_integration" "documents" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.documents.id
  http_method             = aws_api_gateway_method.documents.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${var.nlb_dns_name}/documents"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = var.nlb_vpc_link_id
  request_parameters      = var.request_parameters
  timeout_milliseconds    = 29000
}

resource "aws_api_gateway_resource" "documents_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.documents.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "documents_proxy" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.documents_proxy.id
  http_method        = "ANY"
  authorization      = "CUSTOM"
  authorizer_id      = aws_api_gateway_authorizer.lambda_authorizer.id
  request_parameters = { "method.request.path.proxy" = true }
  api_key_required   = true
}

resource "aws_api_gateway_integration" "documents_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.documents_proxy.id
  http_method             = aws_api_gateway_method.documents_proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${var.nlb_dns_name}/documents/{proxy}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = var.nlb_vpc_link_id
  request_parameters = merge({
    "integration.request.path.proxy" : "method.request.path.proxy",
  }, var.request_parameters)
  timeout_milliseconds = 29000
}

resource "aws_api_gateway_resource" "candidates" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "candidates"
}

resource "aws_api_gateway_method" "candidates" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.candidates.id
  http_method      = "PUT"
  authorization    = "CUSTOM"
  authorizer_id    = aws_api_gateway_authorizer.lambda_authorizer.id
  api_key_required = true
}

resource "aws_api_gateway_integration" "candidates" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.candidates.id
  http_method             = aws_api_gateway_method.candidates.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "PUT"
  uri                     = "http://${var.nlb_dns_name}/candidates"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = var.nlb_vpc_link_id
  request_parameters      = var.request_parameters
  timeout_milliseconds    = 29000
}

#### private _silo_management

resource "aws_api_gateway_resource" "_ops" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "_ops"
}

resource "aws_api_gateway_resource" "_silo_management" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource._ops.id
  path_part   = "silo_management"
}

resource "aws_api_gateway_method" "_silo_management" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource._silo_management.id
  http_method      = "POST"
  authorization    = "AWS_IAM"
  api_key_required = false
}

resource "aws_api_gateway_integration" "_silo_management" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource._silo_management.id
  http_method             = aws_api_gateway_method._silo_management.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  uri                     = "http://${var.nlb_dns_name}/_ops/silo_management"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = var.nlb_vpc_link_id
  timeout_milliseconds    = 29000
}

#########

resource "aws_api_gateway_deployment" "api" {
  depends_on  = [aws_api_gateway_method.proxy]
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_authorizer.lambda_authorizer.id,
      aws_api_gateway_resource.proxy.id,
      aws_api_gateway_method.proxy.id,
      aws_api_gateway_integration.proxy.id,
      aws_api_gateway_integration.proxy.request_parameters,
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
      aws_api_gateway_resource._ops.id,
      aws_api_gateway_resource._silo_management.id,
      aws_api_gateway_method._silo_management.id,
      aws_api_gateway_integration._silo_management.id,
      aws_api_gateway_integration.candidates.request_parameters,
      aws_api_gateway_method.options_cors_proxy.id,
      aws_api_gateway_integration.options_cors_proxy.id,
      aws_api_gateway_method.options_cors_documents.id,
      aws_api_gateway_integration.options_cors_documents.id,
      aws_api_gateway_method.options_cors_documents_proxy.id,
      aws_api_gateway_integration.options_cors_documents_proxy.id,
      aws_api_gateway_rest_api_policy._silo_management.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "stage" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.api.id}/${aws_api_gateway_stage.api.stage_name}"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

resource "aws_api_gateway_method_settings" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.api.stage_name

  method_path = "*/*"
  settings {
    logging_level          = "INFO"
    throttling_burst_limit = var.default_method_throttle_settings.burst_limit
    throttling_rate_limit  = var.default_method_throttle_settings.rate_limit
    metrics_enabled        = var.metrics_enabled_api
  }

  depends_on = [
    aws_cloudwatch_log_group.stage
  ]
}

# cors:
# don't require authentication for OPTIONS (preflight) requests. The requests
# are performed by the browser therefore it can't contain our api token
# the request is handled by the backend
resource "aws_api_gateway_method" "options_cors_proxy" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.proxy.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.path.proxy" = true }
}

resource "aws_api_gateway_integration" "options_cors_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.options_cors_proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${var.nlb_dns_name}/{proxy}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = var.nlb_vpc_link_id
  request_parameters = merge(
    var.request_parameters, {
      "integration.request.path.proxy" : "method.request.path.proxy"
  })
}

resource "aws_api_gateway_method" "options_cors_documents" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.documents.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_cors_documents" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.documents.id
  http_method             = aws_api_gateway_method.options_cors_documents.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${var.nlb_dns_name}/documents"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = var.nlb_vpc_link_id
  request_parameters      = var.request_parameters
}

resource "aws_api_gateway_method" "options_cors_documents_proxy" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.documents_proxy.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  request_parameters = { "method.request.path.proxy" = true }
}

resource "aws_api_gateway_integration" "options_cors_documents_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.documents_proxy.id
  http_method             = aws_api_gateway_method.options_cors_documents_proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${var.nlb_dns_name}/documents/{proxy}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "VPC_LINK"
  connection_id           = var.nlb_vpc_link_id
  request_parameters = merge(
    var.request_parameters, {
      "integration.request.path.proxy" : "method.request.path.proxy"
  })
}

# aws waf
resource "aws_wafv2_web_acl_association" "api_gateway" {
  count        = var.web_acl_arn != null ? 1 : 0
  resource_arn = aws_api_gateway_stage.api.arn
  web_acl_arn  = var.web_acl_arn
}

# CloudWatch alarms
data "aws_caller_identity" "current" {}
module "alarms" {
  providers = {
    aws = aws.monitoring-account
  }
  source = "../../generic/alarms/api_gateway"

  account_id = data.aws_caller_identity.current.account_id
  prefix     = "${data.aws_caller_identity.current.account_id}_"

  api_name  = var.name
  api_stage = aws_api_gateway_stage.api.stage_name

  http_5xx_error    = var.alarm_http_5xx_error
  latency           = var.alarm_latency
  error_rate        = var.alarm_error_rate
  latency_by_method = var.alarm_latency_by_method


  tags = var.tags
}


# Resource Policies

data "aws_iam_policy_document" "_silo_management" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"]
  }
  statement {
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.api.execution_arn}/*/*/_ops/*"]
    condition {
      test     = "StringNotEquals"
      variable = "aws:PrincipalArn"
      values   = [var.provisioning_lambda_role]
    }
  }
}
resource "aws_api_gateway_rest_api_policy" "_silo_management" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  policy      = data.aws_iam_policy_document._silo_management.json
}
