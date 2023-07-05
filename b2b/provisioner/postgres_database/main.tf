module "postgres_database" {
  source = "../../../generic/lambda/invoke"

  create_payload = {
    "command" : "CreateDatabase"
    "tenant" : var.tenant
    "postgres_user_ssm_name" : var.username_ssm_parameter_name
    "postgres_password_ssm_name" : var.password_ssm_parameter_name
    "postgres_url_ssm_name" : var.url_ssm_parameter_name
  }

  delete_payload = {
    "command" : "DeleteDatabase"
    "tenant" : var.tenant
    "postgres_user_ssm_name" : var.username_ssm_parameter_name
    "postgres_password_ssm_name" : var.password_ssm_parameter_name
    "postgres_url_ssm_name" : var.url_ssm_parameter_name
  }

  function_arn = var.function_arn
  aws_profile  = var.aws_profile
}
