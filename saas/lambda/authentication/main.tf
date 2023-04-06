locals {
  function_name = "authentication-app-saas"
  filename      = "${path.module}/index-app-saas.js"
  output_path   = "${path.module}/authentication-app-saas.zip"
}

resource "local_sensitive_file" "authentication_code" {
  content = templatefile("${path.module}/index.js.tpl", {
  })
  filename = local.filename
}

module "role" {
  source = "../../../generic/lambda/role"
  path   = "/saas/"
  prefix = "AppSaas"
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
  handler               = "index-app-saas.handler"
  runtime               = "nodejs16.x"
  source_code_hash      = filebase64sha256(data.external.source_code.result.output)
  output_path           = local.output_path
  lambda_role_arn       = module.role.arn
  log_retention_in_days = var.log_retention_in_days
  tags                  = var.tags
}
