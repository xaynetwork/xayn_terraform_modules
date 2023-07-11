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

resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for k, v in var.exec_iam_role_policies : k => v }

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_sagemaker_model" "this" {
  name               = var.name
  execution_role_arn = aws_iam_role.this.arn

  dynamic "primary_container" {
    for_each = [var.primary_container]

    content {
      image              = try(primary_container.value.image, null)
      mode               = "SingleModel"
      model_data_url     = try(primary_container.value.model_data_url, null)
      model_package_name = try(primary_container.value.model_package_name, null)
      container_hostname = try(primary_container.value.container_hostname, null)
      environment        = try(primary_container.value.environment, null)

      dynamic "image_config" {
        for_each = try([primary_container.value.image_config], [])

        content {
          repository_access_mode = image_config.value.repository_access_mode
          dynamic "repository_auth_config" {
            for_each = try([image_config.value.repository_auth_config], [])

            content {
              repository_credentials_provider_arn = repository_auth_config.value.repository_credentials_provider_arn
            }
          }
        }
      }
    }
  }

  dynamic "vpc_config" {
    for_each = length(var.vpc_config) > 0 ? [var.vpc_config] : []

    content {
      security_group_ids = vpc_config.value.security_group_ids
      subnets            = vpc_config.value.subnets
    }
  }

  enable_network_isolation = var.enable_network_isolation

  tags = var.tags
}
