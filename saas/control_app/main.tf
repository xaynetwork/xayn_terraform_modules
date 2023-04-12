locals {
  function_name         = "authenticator"
  app_path              = "${path.module}/src"
  function_path         = "${local.app_path}/${local.function_name}"
  function_build_path   = "${local.function_path}/build"
  function_zip_filename = "${local.function_name}.zip"
  output_path           = "${local.function_build_path}/${local.function_zip_filename}"
}

# ### needs to have installed
# ### https://github.com/timo-reymann/deterministic-zip
# ### https://www.reddit.com/r/Terraform/comments/aupudn/building_deterministic_zips_to_minimize_lambda/
data "external" "build" {
  program = ["bash", "-c", "${local.app_path}/build.sh \"${local.function_path}\" \"${local.function_build_path}\" \"${local.function_zip_filename}\" Function &> /tmp/temp.log && echo '{ \"output\": \"${local.output_path}\" }'"]
}

module "role" {
  source = "../../generic/lambda/role"
  path   = "/saas/"
  prefix = "AppSaas"
  tags   = var.tags
}

module "authentication_function" {
  source = "../../generic/lambda/function"

  function_name         = local.function_name
  handler               = "app.lambda_handler"
  runtime               = "python3.9"
  source_code_hash      = filebase64sha256(data.external.build.result.output)
  output_path           = local.output_path
  lambda_role_arn       = module.role.arn
  log_retention_in_days = var.log_retention_in_days
  tags                  = var.tags
}
