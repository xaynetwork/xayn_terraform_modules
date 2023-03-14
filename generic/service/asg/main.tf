resource "aws_appautoscaling_target" "service" {
  min_capacity       = var.min_tasks
  max_capacity       = var.max_tasks
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  name               = "${var.service_name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.service.resource_id
  scalable_dimension = aws_appautoscaling_target.service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.service.service_namespace

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
  count              = var.scheduled_scaling != null ? 1 : 0
  name               = "${var.service_name}-scheduled-scaling-out"
  service_namespace  = aws_appautoscaling_target.service.service_namespace
  resource_id        = aws_appautoscaling_target.service.resource_id
  scalable_dimension = aws_appautoscaling_target.service.scalable_dimension
  schedule           = "cron(${var.scheduled_scaling.schedule_out})"

  scalable_target_action {
    min_capacity = var.scheduled_scaling.min_out
    max_capacity = var.scheduled_scaling.max_out
  }
}

resource "aws_appautoscaling_scheduled_action" "scheduled_in" {
  count              = var.scheduled_scaling != null ? 1 : 0
  name               = "${var.service_name}-scheduled-scaling-in"
  service_namespace  = aws_appautoscaling_target.service.service_namespace
  resource_id        = aws_appautoscaling_target.service.resource_id
  scalable_dimension = aws_appautoscaling_target.service.scalable_dimension
  schedule           = "cron(${var.scheduled_scaling.schedule_in})"

  scalable_target_action {
    min_capacity = var.min_tasks
    max_capacity = var.max_tasks
  }
}
