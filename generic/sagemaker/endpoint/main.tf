module "model" {
  source = "../model"

  primary_container        = var.model_primary_container
  enable_network_isolation = var.model_enable_network_isolation
  vpc_config               = var.model_vpc_config

  role_name        = var.model_role_name
  role_description = var.model_role_description
  policy_name      = var.model_policy_name
  policy_jsons     = var.model_policy_jsons
  model_buckets    = var.model_model_buckets
  ecr_repositories = var.model_ecr_repositories
  multi_model_mode = var.model_multi_model_mode

  create_security_group          = var.create_model_security_group
  security_group_name            = var.model_security_group_name
  security_group_use_name_prefix = var.model_security_group_use_name_prefix
  security_group_description     = var.model_security_group_description
  security_group_rules           = var.model_security_group_rules

  tags = var.tags
}

resource "aws_sagemaker_endpoint_configuration" "this" {
  # we cannot set a name here because updating the endpoint config creates a new config with the same name and this will result in a conflict
  # https://github.com/hashicorp/terraform-provider-aws/issues/21811
  name_prefix = var.endpoint_config_name != null ? var.endpoint_config_name : "${var.model_name}-config-"

  dynamic "production_variants" {
    for_each = var.endpoint_config_production_variants

    content {
      container_startup_health_check_timeout_in_seconds = try(production_variants.value.container_startup_health_check_timeout_in_seconds, null)

      dynamic "core_dump_config" {
        for_each = try([production_variants.value.core_dump_config], [])

        content {
          destination_s3_uri = core_dump_config.value.destination_s3_uri
          kms_key_id         = core_dump_config.value.kms_key_id
        }
      }

      enable_ssm_access                      = try(production_variants.value.enable_ssm_access, null)
      initial_instance_count                 = try(production_variants.value.initial_instance_count, null)
      instance_type                          = try(production_variants.value.instance_type, null)
      initial_variant_weight                 = try(production_variants.value.initial_variant_weight, null)
      model_data_download_timeout_in_seconds = try(production_variants.value.model_data_download_timeout_in_seconds, null)
      model_name                             = module.model.name

      dynamic "serverless_config" {
        for_each = try([production_variants.value.serverless_config], [])

        content {
          max_concurrency         = serverless_config.value.max_concurrency
          memory_size_in_mb       = serverless_config.value.memory_size_in_mb
          provisioned_concurrency = try(serverless_config.value.provisioned_concurrency, null)
        }
      }

      variant_name      = try(production_variants.value.variant_name, null)
      volume_size_in_gb = try(production_variants.value.volume_size_in_gb, null)
    }
  }

  kms_key_arn = module.kms.key_arn

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_sagemaker_endpoint" "this" {
  count = var.create_endpoint ? 1 : 0

  name                 = var.endpoint_name != null ? var.endpoint_name : "${var.model_name}-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.this.name

  dynamic "deployment_config" {
    for_each = length(var.endpoint_deployment_config) > 0 ? [var.endpoint_deployment_config] : []

    content {
      dynamic "blue_green_update_policy" {
        for_each = [deployment_config.value.blue_green_update_policy]

        content {
          dynamic "traffic_routing_configuration" {
            for_each = try([blue_green_update_policy.value.traffic_routing_configuration], [])

            content {
              type                     = traffic_routing_configuration.value.type
              wait_interval_in_seconds = traffic_routing_configuration.value.wait_interval_in_seconds
              dynamic "canary_size" {
                for_each = try([blue_green_update_policy.value.canary_size], [])

                content {
                  type  = canary_size.value.type
                  value = canary_size.value.value
                }
              }

              dynamic "linear_step_size" {
                for_each = try([blue_green_update_policy.value.linear_step_size], [])

                content {
                  type  = linear_step_size.value.type
                  value = linear_step_size.value.value
                }
              }
            }
          }

          maximum_execution_timeout_in_seconds = try(blue_green_update_policy.value.maximum_execution_timeout_in_seconds, null)
          termination_wait_in_seconds          = try(blue_green_update_policy.value.termination_wait_in_seconds, null)
        }
      }

      dynamic "auto_rollback_configuration" {
        for_each = try([deployment_config.value.auto_rollback_configuration], [])

        content {
          dynamic "alarms" {
            for_each = try(auto_rollback_configuration.value.alarms, [])

            content {
              alarm_name = alarms.value
            }
          }
        }
      }
    }
  }

  tags = var.tags
}

locals {
  enable_autoscaling = var.enable_autoscaling && var.create_endpoint
}

resource "aws_appautoscaling_target" "this" {
  # if autoscaling is enabled, variant_name need to be set because it is required in the resource_id
  for_each = { for k, v in var.endpoint_config_production_variants : k => v if local.enable_autoscaling && try(v.variant_name, null) != null && try(v.serverless_config, null) == null }

  depends_on = [aws_sagemaker_endpoint.this]

  max_capacity       = max(try(var.autoscaling_capacity[each.value.variant_name].max, 10), try(var.endpoint_config_production_variants[each.key].initial_instance_count, 0))
  min_capacity       = min(try(var.autoscaling_capacity[each.value.variant_name].min, 1), try(var.endpoint_config_production_variants[each.key].initial_instance_count, 0))
  resource_id        = "endpoint/${aws_sagemaker_endpoint.this[0].name}/variant/${var.endpoint_config_production_variants[each.key].variant_name}"
  scalable_dimension = "sagemaker:variant:DesiredInstanceCount"
  service_namespace  = "sagemaker"
}

locals {
  autoscaling_targets           = { for k, v in aws_appautoscaling_target.this : split("endpoint/${aws_sagemaker_endpoint.this[0].name}/variant/", v.resource_id)[1] => v }
  autoscaling_policies          = flatten([for k, l in var.autoscaling_policies : [for e in l : merge(e, { variant_name = k })]])
  autoscaling_scheduled_actions = flatten([for k, l in var.autoscaling_scheduled_actions : [for e in l : merge(e, { variant_name = k })]])
}

resource "aws_appautoscaling_policy" "this" {
  for_each = { for e in local.autoscaling_policies : "${e.variant_name}-${e.name}" => e if contains(keys(local.autoscaling_targets), e.variant_name) }

  name               = each.value.name
  policy_type        = "TargetTrackingScaling"
  resource_id        = local.autoscaling_targets[each.value.variant_name].resource_id
  scalable_dimension = local.autoscaling_targets[each.value.variant_name].scalable_dimension
  service_namespace  = local.autoscaling_targets[each.value.variant_name].service_namespace


  dynamic "target_tracking_scaling_policy_configuration" {
    for_each = try([each.value.target_tracking_scaling_policy_configuration], [])

    content {

      dynamic "customized_metric_specification" {
        for_each = try([target_tracking_scaling_policy_configuration.value.customized_metric_specification], [])

        content {
          dynamic "dimensions" {
            for_each = try(customized_metric_specification.value.dimensions, [])

            content {
              name  = dimensions.value.name
              value = dimensions.value.value
            }
          }

          metric_name = customized_metric_specification.value.metric_name
          namespace   = customized_metric_specification.value.namespace
          statistic   = customized_metric_specification.value.statistic
          unit        = try(customized_metric_specification.value.unit, null)
        }
      }

      disable_scale_in = try(target_tracking_scaling_policy_configuration.value.disable_scale_in, null)

      dynamic "predefined_metric_specification" {
        for_each = try([target_tracking_scaling_policy_configuration.value.predefined_metric_specification], [])

        content {
          predefined_metric_type = predefined_metric_specification.value.predefined_metric_type
          resource_label         = try(predefined_metric_specification.value.resource_label, null)
        }
      }

      scale_in_cooldown  = try(target_tracking_scaling_policy_configuration.value.scale_in_cooldown, 300)
      scale_out_cooldown = try(target_tracking_scaling_policy_configuration.value.scale_out_cooldown, 60)
      target_value       = try(target_tracking_scaling_policy_configuration.value.target_value, 75)
    }
  }
}

resource "aws_appautoscaling_scheduled_action" "this" {
  for_each = { for e in local.autoscaling_scheduled_actions : "${e.variant_name}-${e.name}" => e if contains(keys(local.autoscaling_targets), e.variant_name) }

  name               = try(each.value.name, each.key)
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension

  scalable_target_action {
    min_capacity = each.value.min_capacity
    max_capacity = each.value.max_capacity
  }

  schedule   = each.value.schedule
  start_time = try(each.value.start_time, null)
  end_time   = try(each.value.end_time, null)
  timezone   = try(each.value.timezone, null)
}

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.5.0"

  create = var.create_kms

  deletion_window_in_days = 7
  description             = "KMS for SageMaker. It is used to encrypt data on the storage volume attached to the ML compute instance that hosts the endpoint."
  enable_key_rotation     = false
  is_enabled              = true
  key_usage               = "ENCRYPT_DECRYPT"

  tags = var.tags
}

data "aws_region" "current" {}

locals {
  endpoint_url = try(aws_sagemaker_endpoint.this[0].name, null) != null ? "https://runtime.sagemaker.${data.aws_region.current.name}.amazonaws.com/endpoints/${aws_sagemaker_endpoint.this[0].name}/invocations" : null
}

module "endpoint_url" {
  source  = "terraform-aws-modules/ssm-parameter/aws"
  version = "1.1.0"

  create = var.create_ssm_parm && var.create_endpoint

  name        = "/sagemaker/${var.model_name}/endpoint_url"
  description = "URL of the sagemaker endpoint."
  value       = local.endpoint_url
  tags        = var.tags
}
