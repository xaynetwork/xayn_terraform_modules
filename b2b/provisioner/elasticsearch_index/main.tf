module "elasticsearch_index" {
  source = "../../../generic/lambda/invoke"

  create_payload = {
    "command" : "CreateIndex"
    "tenant" : var.tenant
    "elasticsearch_user_ssm_name" : var.username_ssm_parameter_name
    "elasticsearch_password_ssm_name" : var.password_ssm_parameter_name
    "elasticsearch_url_ssm_name" : var.url_ssm_parameter_name
    "elasticsearch_index_embedding_dims" : var.embedding_dims
  }

  delete_payload = {
    "command" : "DeleteIndex"
    "tenant" : var.tenant
    "elasticsearch_user_ssm_name" : var.username_ssm_parameter_name
    "elasticsearch_password_ssm_name" : var.password_ssm_parameter_name
    "elasticsearch_url_ssm_name" : var.url_ssm_parameter_name
    "elasticsearch_index_embedding_dims" : var.embedding_dims
  }

  function_arn = var.function_arn
  aws_profile  = var.aws_profile
}
