module "model" {
  source = "../model"

  name                     = var.model_name
  primary_container        = var.model_primary_container
  enable_network_isolation = var.model_enable_network_isolation
  vpc_config               = var.model_vpc_config

  tags = var.tags
}

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.5.0"

  deletion_window_in_days = 7
  description             = "KMS for SageMaker. It is used to encrypt data on the storage volume attached to the ML compute instance that hosts the endpoint."
  enable_key_rotation     = false
  is_enabled              = true
  key_usage               = "ENCRYPT_DECRYPT"

  tags = var.tags
}

resource "aws_sagemaker_endpoint_configuration" "this" {
  name = var.endpoint_config_name != null ? var.endpoint_config_name : "${var.model_name}-config"

  dynamic "production_variants" {
    for_each = [var.endpoint_config_production_variant]

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
        for_each = try([var.endpoint_config_production_variant.value.serverless_config], [])

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
}

resource "aws_sagemaker_endpoint" "this" {
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
  enable_autoscaling = var.enable_autoscaling && try(var.endpoint_config_production_variant.value.serverless_config, null) == null
}

resource "aws_appautoscaling_target" "this" {
  count = local.enable_autoscaling ? 1 : 0

  max_capacity       = max(var.autoscaling_max_capacity, try(var.endpoint_config_production_variant.value.initial_instance_count, 0))
  min_capacity       = min(var.autoscaling_min_capacity, try(var.endpoint_config_production_variant.value.initial_instance_count, 0))
  resource_id        = "endpoint/${aws_sagemaker_endpoint.this.name}/variant/${var.endpoint_config_production_variant.value.variant_name}"
  scalable_dimension = "sagemaker:variant:DesiredInstanceCount"
  service_namespace  = "sagemaker"
}

resource "aws_appautoscaling_policy" "this" {
  for_each = { for k, v in var.autoscaling_policies : k => v if local.enable_autoscaling }

  name               = try(each.value.name, each.key)
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace


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
  for_each = { for k, v in var.autoscaling_scheduled_actions : k => v if local.enable_autoscaling }

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
