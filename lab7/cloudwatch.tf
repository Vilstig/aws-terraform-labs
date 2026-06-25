resource "aws_sns_topic" "alarms" {
  name = "${var.name_prefix}-alarms"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

resource "aws_cloudwatch_metric_alarm" "frontend_cpu" {
  alarm_name          = "${var.name_prefix}-frontend-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cpu_alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cpu_alarm_period
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "Wysokie wykorzystanie CPU serwisu ECS frontend"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.frontend.name
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions      = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "backend_cpu" {
  alarm_name          = "${var.name_prefix}-backend-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cpu_alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cpu_alarm_period
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "Wysokie wykorzystanie CPU serwisu ECS backend"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.backend.name
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions      = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "frontend_unhealthy_hosts" {
  alarm_name          = "${var.name_prefix}-frontend-unhealthy-hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alb_alarm_evaluation_periods
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = var.alb_alarm_period
  statistic           = "Maximum"
  threshold           = var.alb_unhealthy_threshold
  alarm_description   = "Niedostepne cele frontend w target group ALB"

  dimensions = {
    LoadBalancer = aws_lb.app_alb.arn_suffix
    TargetGroup  = aws_lb_target_group.frontend_tg.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions      = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "backend_unhealthy_hosts" {
  alarm_name          = "${var.name_prefix}-backend-unhealthy-hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alb_alarm_evaluation_periods
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = var.alb_alarm_period
  statistic           = "Maximum"
  threshold           = var.alb_unhealthy_threshold
  alarm_description   = "Niedostepne cele backend w target group ALB"

  dimensions = {
    LoadBalancer = aws_lb.app_alb.arn_suffix
    TargetGroup  = aws_lb_target_group.backend_tg.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions      = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "frontend_5xx" {
  alarm_name          = "${var.name_prefix}-frontend-5xx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alb_alarm_evaluation_periods
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.alb_alarm_period
  statistic           = "Sum"
  threshold           = var.alb_5xx_threshold
  treat_missing_data  = "notBreaching"
  alarm_description   = "Bledy HTTP 5xx zwracane przez cele frontend"

  dimensions = {
    LoadBalancer = aws_lb.app_alb.arn_suffix
    TargetGroup  = aws_lb_target_group.frontend_tg.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions      = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "backend_5xx" {
  alarm_name          = "${var.name_prefix}-backend-5xx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alb_alarm_evaluation_periods
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.alb_alarm_period
  statistic           = "Sum"
  threshold           = var.alb_5xx_threshold
  treat_missing_data  = "notBreaching"
  alarm_description   = "Bledy HTTP 5xx zwracane przez cele backend"

  dimensions = {
    LoadBalancer = aws_lb.app_alb.arn_suffix
    TargetGroup  = aws_lb_target_group.backend_tg.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions      = [aws_sns_topic.alarms.arn]
}
