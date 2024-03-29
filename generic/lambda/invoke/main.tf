data "aws_region" "current" {}

locals {
  output_filename = "${sha1(var.function_arn)}.json"
  program_create  = "${path.module}/scripts/invoke.sh ${var.function_arn} ${base64encode(jsonencode(var.create_payload))} ${local.output_filename} ${var.aws_profile} ${data.aws_region.current.name}"
  program_delete  = "${path.module}/scripts/invoke.sh ${var.function_arn} ${base64encode(jsonencode(var.delete_payload))} ${local.output_filename} ${var.aws_profile} ${data.aws_region.current.name}"
}

resource "shell_script" "invoke_lambda" {
  lifecycle_commands {
    create = local.program_create
    delete = local.program_delete
    update = "${path.module}/scripts/update.sh"
  }
}
