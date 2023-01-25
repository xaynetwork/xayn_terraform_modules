locals {
  output_filename = "${sha1(var.function_arn)}.json"
  program_create  = "${path.module}/scripts/invoke.sh ${var.function_arn} ${base64encode(jsonencode(var.create_payload))} ${local.output_filename} ${var.aws_profile}"
  program_delete  = "${path.module}/scripts/invoke.sh ${var.function_arn} ${base64encode(jsonencode(var.delete_payload))} ${local.output_filename} ${var.aws_profile}"
}

resource "shell_script" "invoke_lambda" {
  lifecycle_commands {
    create = local.program_create
    delete = var.skip_delete ? "${path.module}/scripts/fake_delete.sh" : local.program_delete
    update = "${path.module}/scripts/update.sh"
  }
}
