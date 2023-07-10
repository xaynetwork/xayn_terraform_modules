
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
    for_each = length(var.production_variants) > 0 ? [var.production_variants] : []

    content {
      variant_name                                      = try(production_variants.value.variant_name, null)
      model_name                                        = module.model.name
      initial_instance_count                            = try(production_variants.value.initial_instance_count, null)
      instance_type                                     = try(production_variants.value.instance_type, null)
      core_dump_config                                  = try(production_variants.value.core_dump_config, null)
      enable_ssm_access                                 = try(production_variants.value.enable_ssm_access, null)
      container_startup_health_check_timeout_in_seconds = try(production_variants.value.container_startup_health_check_timeout_in_seconds, null)
      initial_variant_weight                            = try(production_variants.value.initial_variant_weight, null)
      model_data_download_timeout_in_seconds            = try(production_variants.value.model_data_download_timeout_in_seconds, null)
      serverless_config                                 = try(production_variants.value.serverless_config, null)
      volume_size_in_gb                                 = try(production_variants.value.volume_size_in_gb, null)
    }
  }

  kms_key_arn = module.kms.key_arn

  tags = var.tags
}

resource "aws_sagemaker_endpoint" "this" {
  name                 = var.endpoint_name != null ? var.endpoint_name : "${var.model_name}-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.this.name
  deployment_config    = var.endpoint_deployment_config

  tags = var.tags
}

locals {
  enable_autoscaling = var.enable_autoscaling && try(production_variants.value.serverless_config, null) == null
}

resource "aws_appautoscaling_target" "this" {
  count = local.enable_autoscaling ? 1 : 0

  max_capacity       = max(var.autoscaling_max_capacity, try(production_variants.value.initial_instance_count, 0))
  min_capacity       = min(var.autoscaling_min_capacity, try(production_variants.value.initial_instance_count, 0))
  resource_id        = "endpoint/${aws_sagemaker_endpoint.this.name}/variant/${production_variants.value.variant_name}"
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
    for_each = try([var.target_tracking_scaling_policy_configuration], [])

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
