resource "aws_key_pair" "k8s-keypair" {
  key_name   = "k8s-keypair"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}


################
# Template files
################

data "template_file" "node_shell" {
  template = file("node_shell.sh")
  vars = {
    kubeadm_token     = var.K8S_TOKEN
    master_ip         = aws_eip.master.public_ip
    master_private_ip = aws_instance.node_master.private_ip
  }
}

################
# Cloud init config
################
data "template_cloudinit_config" "cloudinit-node" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "node_shell.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.node_shell.rendered
  }
}




resource "aws_eip" "master" {
  vpc = true
}

resource "aws_instance" "node_master" {
  ami                    = "ami-00798d7180f25aac2"
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.k8s-keypair.key_name
  vpc_security_group_ids = [aws_security_group.security-group-cluster.id]
  iam_instance_profile   = aws_iam_instance_profile.master_profile2.name
  #user_data              = data.template_cloudinit_config.cloudinit-master.rendered
  subnet_id              = aws_subnet.main-public-1.id
 provisioner "file" {
    #nested connection
    connection {
      type        = "ssh"
      host        = aws_instance.node_master.public_ip
      user        = "ec2-user"
      private_key = file(var.PATH_TO_PRIVATE_KEY)
    }
    source      = "master_shell2.sh"
    destination = "/tmp/master_shell2.sh"
  }

  provisioner "remote-exec"{
        #nested connection
    connection {
      type        = "ssh"
      host        = aws_instance.node_master.public_ip
      user        = "ec2-user"
      private_key = file(var.PATH_TO_PRIVATE_KEY)
    }
      inline=[
          "cd /tmp",
          "sudo mv master_shell2.sh ~/",
          "cd ~",
          "sudo chmod +x master_shell2.sh",
          "ls -l master_shell2.sh",
          "sudo ./master_shell2.sh ${var.K8S_TOKEN}"
      ]
    }
  tags = {
    Name = "Master"
  }
}


resource "aws_eip_association" "master_assoc" {
  instance_id   = aws_instance.node_master.id
  allocation_id = aws_eip.master.id
}

########
#Workers
########

resource "aws_launch_configuration" "nodes" {
  name_prefix          = "ecs-launchconfig"
  image_id             = "ami-00798d7180f25aac2"
  instance_type        = "t2.medium"
  key_name             = aws_key_pair.k8s-keypair.key_name
  iam_instance_profile = aws_iam_instance_profile.node_profile2.name
  security_groups      = [aws_security_group.security-group-cluster.id]
  user_data            = data.template_cloudinit_config.cloudinit-node.rendered
  lifecycle { create_before_destroy = true }
}

resource "aws_autoscaling_group" "ecs-example-autoscaling" {
  name                 = "ecs-example-autoscaling"
  launch_configuration = aws_launch_configuration.nodes.name
  min_size             = var.MIN_ASG
  max_size             = var.MAX_ASG
  vpc_zone_identifier  = [aws_subnet.main-private-3.id]
  health_check_grace_period = 300 #in seconds
  health_check_type         = "ELB"
  load_balancers            = [aws_elb.my-elb.name]
  tag {
    key                 = "Name"
    value               = "cluster-nodes"
    propagate_at_launch = true
  }
}