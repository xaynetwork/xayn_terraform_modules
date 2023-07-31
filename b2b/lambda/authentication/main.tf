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

resource "aws_api_gateway_api_key" "ext_users" {
  name        = "${var.tenant}_ext_users"
  tags        = var.tags
  description = "The external api key for /users."
  value       = var.api_key_value_users
}

resource "aws_api_gateway_api_key" "ext_documents" {
  name        = "${var.tenant}_ext_documents"
  tags        = var.tags
  description = "The external api key for /documents."
  value       = var.api_key_value_documents
}

resource "local_sensitive_file" "authentication_code" {
  content = templatefile("${path.module}/index.js.tpl", {
    api_key : aws_api_gateway_api_key.tenant.value,
    api_key_users : aws_api_gateway_api_key.ext_users.value,
    api_key_documents : aws_api_gateway_api_key.ext_documents.value
  })
  filename = local.filename
}

module "role" {
  source = "../../../generic/lambda/role"
  path   = "/${var.tenant}/"
  prefix = title(var.tenant)
  tags   = var.tags
}

### needs to have installed
### https://github.com/timo-reymann/deterministic-zip
### https://www.reddit.com/r/Terraform/comments/aupudn/building_deterministic_zips_to_minimize_lambda/
data "external" "source_code" {
  program = ["bash", "-c", "deterministic-zip -r ${local.output_path} ${local.filename} && echo '{ \"output\": \"${local.output_path}\" }'"]

  depends_on = [
    local_sensitive_file.authentication_code
  ]
}

module "function" {
  source = "../../../generic/lambda/function"

  function_name         = local.function_name
  handler               = "index-${var.tenant}.handler"
  runtime               = "nodejs16.x"
  source_code_hash      = filebase64sha256(data.external.source_code.result.output)
  output_path           = local.output_path
  lambda_role_arn       = module.role.arn
  log_retention_in_days = var.log_retention_in_days
  tags                  = var.tags
}
