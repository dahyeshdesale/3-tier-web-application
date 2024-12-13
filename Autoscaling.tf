resource "aws_autoscaling_group" "app_asg" {
  launch_configuration = aws_launch_configuration.app.id
  vpc_zone_identifier  = [aws_subnet.private1.id, aws_subnet.private2.id]
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2

  tag {
    key                 = "Name"
    value               = "app-instance"
    propagate_at_launch = true
  }

  health_check_grace_period = 300
  health_check_type         = "EC2"
}
