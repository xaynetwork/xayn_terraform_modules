locals {
  with_scheduled = length(var.scheduled_scaling) > 0 ? true : false
}

resource "aws_appautoscaling_target" "service" {
  count              = local.with_scheduled != true ? 1 : 0
  min_capacity       = var.min_tasks
  max_capacity       = var.max_tasks
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_target" "service_with_scheduled" {
  count              = local.with_scheduled ? 1 : 0
  min_capacity       = var.min_tasks
  max_capacity       = var.max_tasks
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  lifecycle {
    ignore_changes = [
      min_capacity,
      max_capacity
    ]
  }
}

resource "aws_appautoscaling_policy" "cpu" {
  name               = "${var.service_name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = local.with_scheduled ? aws_appautoscaling_target.service_with_scheduled[0].resource_id : aws_appautoscaling_target.service[0].resource_id
  scalable_dimension = local.with_scheduled ? aws_appautoscaling_target.service_with_scheduled[0].scalable_dimension : aws_appautoscaling_target.service[0].scalable_dimension
  service_namespace  = local.with_scheduled ? aws_appautoscaling_target.service_with_scheduled[0].service_namespace : aws_appautoscaling_target.service[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}

resource "aws_appautoscaling_scheduled_action" "scheduled_out" {
  count      = length(var.scheduled_scaling)
  depends_on = [aws_appautoscaling_policy.cpu]

  name               = "${var.service_name}-scheduled-scaling-out-${count.index}"
  service_namespace  = aws_appautoscaling_target.service_with_scheduled[0].service_namespace
  resource_id        = aws_appautoscaling_target.service_with_scheduled[0].resource_id
  scalable_dimension = aws_appautoscaling_target.service_with_scheduled[0].scalable_dimension
  schedule           = "cron(${var.scheduled_scaling[count.index].schedule_out})"
  timezone           = var.scheduled_scaling[count.index].timezone

  scalable_target_action {
    min_capacity = var.scheduled_scaling[count.index].min_out
    max_capacity = var.scheduled_scaling[count.index].max_out
  }
}

resource "aws_appautoscaling_scheduled_action" "scheduled_in" {
  count = length(var.scheduled_scaling)
  # https://stackoverflow.com/questions/61081382/scheduled-ecs-scaling-using-terraform
  depends_on = [aws_appautoscaling_scheduled_action.scheduled_out]

  name               = "${var.service_name}-scheduled-scaling-in-${count.index}"
  service_namespace  = aws_appautoscaling_target.service_with_scheduled[0].service_namespace
  resource_id        = aws_appautoscaling_target.service_with_scheduled[0].resource_id
  scalable_dimension = aws_appautoscaling_target.service_with_scheduled[0].scalable_dimension
  schedule           = "cron(${var.scheduled_scaling[count.index].schedule_in})"
  timezone           = var.scheduled_scaling[count.index].timezone

  scalable_target_action {
    min_capacity = var.min_tasks
    max_capacity = var.max_tasks
  }
}
