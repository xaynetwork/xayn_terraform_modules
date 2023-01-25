module "elasticsearch_index" {
  source = "../../../generic/lambda/invoke"

  create_payload = {
    "command" : "CreateIndex"
    "tenant" : var.tenant
    "elasticsearch_user_ssm_name" : var.username_ssm_parameter_name
    "elasticsearch_password_ssm_name" : var.password_ssm_parameter_name
    "elasticsearch_url_ssm_name" : var.url_ssm_parameter_name
  }

  delete_payload = {
    "command" : "DeleteIndex"
    "tenant" : var.tenant
    "elasticsearch_user_ssm_name" : var.username_ssm_parameter_name
    "elasticsearch_password_ssm_name" : var.password_ssm_parameter_name
    "elasticsearch_url_ssm_name" : var.url_ssm_parameter_name
  }

  function_arn = var.function_arn
  skip_delete  = var.skip_delete
  aws_profile  = var.aws_profile
}
