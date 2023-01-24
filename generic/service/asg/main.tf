resource "aws_appautoscaling_target" "service" {
  max_capacity       = var.max_tasks
  min_capacity       = var.min_tasks
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

# resource "aws_appautoscaling_scheduled_action" "schedule" {
#   name               = "${var.service_name}-scheduled-autoscaling"
#   resource_id        = aws_appautoscaling_target.service.resource_id
#   scalable_dimension = aws_appautoscaling_target.service.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.service.service_namespace
#   schedule           = "cron()"

#   scalable_target_action {
#     min_capacity = 1
#     max_capacity = 200
#   }
# }