locals {
  function_name = "authentication-${var.tenant}"
  filename      = "${path.module}/index-${var.tenant}.js"
  output_path   = "${path.module}/authentication-${var.tenant}.zip"
}

resource "aws_api_gateway_api_key" "tenant" {
  name        = var.tenant
  tags        = var.tags
  description = "The internal api key of ${var.tenant}, do not share."
}

resource "local_sensitive_file" "authentication_code" {
  content = templatefile("${path.module}/index.js.tpl", {
    api_key : aws_api_gateway_api_key.tenant.value,
  })
  filename = local.filename
}

module "role" {
  source = "../../../generic/lambda/role"
  path   = "/${var.tenant}/"
  prefix = title(var.tenant)
  tags   = var.tags
}

data "archive_file" "source_code" {
  type        = "zip"
  source_file = local.filename
  output_path = local.output_path

  depends_on = [local_sensitive_file.authentication_code]
}

module "function" {
  source = "../../../generic/lambda/function"

  function_name         = local.function_name
  handler               = "index-${var.tenant}.handler"
  runtime               = "nodejs16.x"
  source_code_hash      = data.archive_file.source_code.output_base64sha256
  output_path           = local.output_path
  lambda_role_arn       = module.role.arn
  log_retention_in_days = var.log_retention_in_days
  tags                  = var.tags
}
