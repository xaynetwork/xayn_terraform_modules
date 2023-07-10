data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_sagemaker_model" "this" {
  name               = var.name
  execution_role_arn = aws_iam_role.this.arn

  dynamic "primary_container" {
    for_each = length(var.primary_container) > 0 ? [var.primary_container] : []

    content {
      image              = try(primary_container.value.image, null)
      mode               = "SingleModel"
      model_data_url     = try(primary_container.value.model_data_url, null)
      model_package_name = try(primary_container.value.model_package_name, null)
      container_hostname = try(primary_container.value.container_hostname, null)
      environment        = try(primary_container.value.environment, null)
      image_config       = try(primary_container.value.image_config, null)
    }
  }

  dynamic "vpc_config" {
    for_each = length(var.vpc_config) > 0 ? [var.vpc_config] : []

    content {
      security_group_ids = try(vpc_config.value.security_group_ids, null)
      subnets            = try(vpc_config.subnets.mode, null)
      vpc_id             = try(vpc_config.value.vpc_id, null)

    }
  }

  enable_network_isolation = var.enable_network_isolation

  tags = var.tags
}
