locals {

  hf_create = jsonencode(
    {
      "name" : var.hf_name,
      "type" : "protected",
      "accountId" : null,
      "provider" : {
        "vendor" : "aws",
        "region" : var.hf_region
      },
      "compute" : {
        "accelerator" : "gpu",
        "instanceType" : var.instance_type,
        "instanceSize" : var.instance_size,
        "scaling" : {
          "minReplica" : var.min_replica,
          "maxReplica" : var.max_replica
        }
      },
      "model" : {
        "repository" : var.model_repo,
        "task" : var.task,
        "framework" : var.framework,
        "image" : {
          "custom" : {
            "url" : var.image_url,
            "health_route" : "/health",
            "env" : var.env_var
          }
        }
      }
  })
  base64_encoded_hf_create = base64encode(local.hf_create)

  hf_update = jsonencode(
    {
      "compute" : {
        "accelerator" : "gpu",
        "instanceType" : var.instance_type,
        "instanceSize" : var.instance_size,
        "scaling" : {
          "minReplica" : var.min_replica,
          "maxReplica" : var.max_replica
        }
      },
      "model" : {
        "framework" : var.framework,
        "image" : {
          "huggingface" : {}
        },
        "repository" : var.model_repo,
        "task" : var.task,
      }
    }
  )
  base64_encoded_hf_update = base64encode(local.hf_update)
}


locals {
  program_create = "${path.module}/scripts/create_hf.sh ${var.namespace} ${var.write_token} ${local.base64_encoded_hf_create}"
  program_delete = "${path.module}/scripts/delete_hf.sh  ${var.namespace} ${var.write_token} ${var.hf_name}"
  program_update = "${path.module}/scripts/update_hf.sh  ${var.namespace} ${var.write_token} ${var.hf_name} ${local.base64_encoded_hf_update}"
  program_read   = "${path.module}/scripts/read_hf.sh  ${var.namespace} ${var.read_token} ${var.hf_name}"
}

resource "shell_script" "invoke_hf" {
  lifecycle_commands {
    create = local.program_create
    delete = local.program_delete
    update = local.program_update
    read   = local.program_read
  }

  triggers = {
    when_value_changed = "${var.namespace} ${var.write_token} ${local.base64_encoded_hf_create} ${local.base64_encoded_hf_update}"
  }
}
