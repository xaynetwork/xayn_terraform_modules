resource "aws_sagemaker_model" "this" {
  depends_on = [aws_iam_role_policy_attachment.additional_jsons]

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
      security_group_ids = local.security_groups
      subnets            = vpc_config.value.subnets
    }
  }

  enable_network_isolation = var.enable_network_isolation

  tags = var.tags
}

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
  name               = var.role_name
  description        = var.role_description
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "additional_jsons" {
  count = length(var.policy_jsons)

  name   = "${var.policy_name}-${count.index}"
  policy = var.policy_jsons[count.index]
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "additional_jsons" {
  count = length(var.policy_jsons)

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.additional_jsons[count.index].arn
}

locals {
  create_security_group = var.create_security_group && length(var.vpc_config) > 0
  security_group_name   = try(var.security_group_name, "")
  security_groups       = flatten(concat([try(aws_security_group.this[0].id, [])], try(var.vpc_config.security_group_ids, [])))
}

data "aws_subnet" "this" {
  count = local.create_security_group ? 1 : 0

  id = element(var.vpc_config.subnets, 0)
}

resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

  name        = var.security_group_use_name_prefix ? null : local.security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${local.security_group_name}-" : null
  description = var.security_group_description
  vpc_id      = data.aws_subnet.this[0].vpc_id

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "this" {
  for_each = { for k, v in var.security_group_rules : k => v if local.create_security_group }

  security_group_id = aws_security_group.this[0].id
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  type              = each.value.type

  description              = try(each.value.description, null)
  cidr_blocks              = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks         = try(each.value.ipv6_cidr_blocks, null)
  prefix_list_ids          = try(each.value.prefix_list_ids, null)
  self                     = try(each.value.self, null)
  source_security_group_id = try(each.value.source_security_group_id, null)
}
