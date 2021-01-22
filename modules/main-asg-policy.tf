#scaling up 
resource "aws_autoscaling_policy" "cpu-policy-scale-up" {
  name                   = "cpu-policy-scale-up"
  autoscaling_group_name = aws_autoscaling_group.ecs-example-autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "cpu-alarm-scale-up" {
  alarm_name          = "cpu-alarm-scale-up"
  alarm_description   = "cpu-alarm-scale-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "55" #%

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.ecs-example-autoscaling.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.cpu-policy-scale-up.arn]
}

#scaling down
resource "aws_autoscaling_policy" "cpu-policy-scaling-down" {
  name                   = "cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.ecs-example-autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"  # down 1 
  cooldown               = "300" #seconds
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "cpu-alarm-scaling-down" {
  alarm_name          = "cpu-alarm-scaling-down"
  alarm_description   = "cpu-alarm-scaling-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.ecs-example-autoscaling.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.cpu-policy-scaling-down.arn]
}