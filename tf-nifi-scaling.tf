# launch conf
resource "aws_launch_configuration" "tf-nifi-launchconf" {
  name_prefix             = "tf-nifi-launchconf-"
  image_id                = aws_ami_copy.tf-nifi-latest-vendor-ami-with-cmk.id
  instance_type           = var.instance_type
  key_name                = aws_key_pair.tf-nifi-instance-key.key_name
  iam_instance_profile    = aws_iam_instance_profile.tf-nifi-instance-profile.name
  security_groups         = [aws_security_group.tf-nifi-prisg1.id]
  user_data               = <<EOF
#!/bin/bash
# install epel
https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# install yum packages
yum -y install ansible jq java-1.8.0-openjdk python2-pip
# install pip packages
/bin/pip install boto boto3 botocore
EOF
  root_block_device {
    volume_size             = var.instance_vol_size
    volume_type             = "standard"
    encrypted               = "true"
  }
  lifecycle {
    create_before_destroy   = true
  }
}

# autoscaling group
resource "aws_autoscaling_group" "tf-nifi-autoscalegroup" {
  name_prefix             = "tf-nifi-autoscalegroup-"
  launch_configuration    = aws_launch_configuration.tf-nifi-launchconf.name
  load_balancers          = [aws_elb.tf-nifi-elb.name]
  health_check_type       = "ELB"
  health_check_grace_period = 1800
  vpc_zone_identifier     = [aws_subnet.tf-nifi-prinet1.id, aws_subnet.tf-nifi-prinet2.id, aws_subnet.tf-nifi-prinet3.id]
  service_linked_role_arn = aws_iam_service_linked_role.tf-nifi-autoscale-slr.arn
  termination_policies    = ["ClosestToNextInstanceHour"]
  min_size                = var.minimum_node_count
  max_size                = var.maximum_node_count
  lifecycle {
    create_before_destroy   = true
  }
  tags =                  concat(
    [
      {
        key                     = "Name"
        value                   = "${var.ec2_name_prefix}-nifi-node"
        propagate_at_launch     = true
      },
      {
        key                     = "NiFi"
        value                   = "node"
        propagate_at_launch     = true
      }
    ]
  )
  depends_on              = [aws_iam_role_policy_attachment.tf-nifi-iam-attach-ssm, aws_iam_role_policy_attachment.tf-nifi-iam-attach-s3]
}

# scale up policy and metric alarm
resource "aws_autoscaling_policy" "tf-nifi-autoscalepolicy-up" {
  name                    = "tf-nifi-autoscalepolicy-up"
  autoscaling_group_name  = aws_autoscaling_group.tf-nifi-autoscalegroup.name
  adjustment_type         = "ChangeInCapacity"
  scaling_adjustment      = "1"
  cooldown                = "600"
  policy_type             = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "tf-nifi-cpu-metric-alarm-up" {
  alarm_name              = "tf-nifi-cpu-metric-alarm-up"
  alarm_description       = "Alarm for NiFi autoscaling group high CPU utilization average."
  namespace               = "AWS/EC2"
  metric_name             = "CPUUtilization"
  comparison_operator     = "GreaterThanOrEqualToThreshold"
  statistic               = "Average"
  threshold               = "75"
  evaluation_periods      = "10"
  period                  = "60"
  dimensions              = {
    "AutoScalingGroupName" = aws_autoscaling_group.tf-nifi-autoscalegroup.name
  }
  actions_enabled         = true
  alarm_actions           = [aws_autoscaling_policy.tf-nifi-autoscalepolicy-up.arn]
}

# scale down policy and metric alarm
resource "aws_autoscaling_policy" "tf-nifi-autoscalepolicy-down" {
  name                    = "tf-nifi-autoscalepolicy-down"
  autoscaling_group_name  = aws_autoscaling_group.tf-nifi-autoscalegroup.name
  adjustment_type         = "ChangeInCapacity"
  scaling_adjustment      = "-1"
  cooldown                = "600"
  policy_type             = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "tf-nifi-cpu-metric-alarm-down" {
  alarm_name              = "tf-nifi-cpu-metric-alarm-down"
  alarm_description       = "Alarm for NiFi autoscaling group low CPU utilization average."
  namespace               = "AWS/EC2"
  metric_name             = "CPUUtilization"
  comparison_operator     = "LessThanOrEqualToThreshold"
  statistic               = "Average"
  threshold               = "25"
  evaluation_periods      = "10"
  period                  = "60"
  dimensions              = {
    "AutoScalingGroupName" = aws_autoscaling_group.tf-nifi-autoscalegroup.name
  }
  actions_enabled         = true
  alarm_actions           = [aws_autoscaling_policy.tf-nifi-autoscalepolicy-down.arn]
}
