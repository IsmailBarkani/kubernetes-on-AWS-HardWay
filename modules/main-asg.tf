data "template_file" "node_shell" {
  template = file("./modules/add-ons/add-on-shell/node_shell.sh")
  vars = {
    kubeadm_token     = var.K8S_TOKEN
    master_ip         = aws_eip.master.public_ip
    master_private_ip = aws_instance.node_master.private_ip
  }
}


data "template_cloudinit_config" "cloudinit-node" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "node_shell.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.node_shell.rendered
  }
}


resource "aws_launch_configuration" "nodes" {
  name_prefix          = "ecs-launchconfig"
  image_id             = var.AWS_AMI
  instance_type        = var.INSTANCE_WORKER_TYPE
  key_name             = aws_key_pair.k8s-keypair.key_name
  iam_instance_profile = aws_iam_instance_profile.node_profile_1.name
  security_groups      = [aws_security_group.security-group-cluster.id]
  user_data            = data.template_cloudinit_config.cloudinit-node.rendered
  lifecycle { create_before_destroy = true }
}

resource "aws_autoscaling_group" "ecs-example-autoscaling" {
  name                      = "ecs-example-autoscaling"
  launch_configuration      = aws_launch_configuration.nodes.name
  min_size                  = var.MIN_ASG
  max_size                  = var.MAX_ASG
  vpc_zone_identifier       = [aws_subnet.main-public-1.id]
  health_check_grace_period = 300 #in seconds
  health_check_type         = "EC2"
  target_group_arns = [aws_lb_target_group.asg.arn]
  force_delete              = true
  tag {
    key                 = "Name"
    value               = "Worker"
    propagate_at_launch = true
  }
}