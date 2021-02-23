resource "aws_key_pair" "k8s-keypair" {
  key_name   = "k8s-keypair"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "aws_eip" "master" {
  vpc = true
}


resource "aws_eip_association" "master_assoc" {
  instance_id   = aws_instance.node_master.id
  allocation_id = aws_eip.master.id
}

resource "aws_instance" "node_master" {
  ami                    = var.AWS_AMI
  instance_type          = var.INSTANCE_MASTER_TYPE
  key_name               = aws_key_pair.k8s-keypair.key_name
  vpc_security_group_ids = [aws_security_group.security-group-cluster.id]
  iam_instance_profile   = aws_iam_instance_profile.master_profile_1.name
  subnet_id = aws_subnet.main-public-1.id
  connection {
      type        = "ssh"
      host        = aws_instance.node_master.public_ip
      user        = var.AWS_INSTANCE_USERNAME
      private_key = file(var.PATH_TO_PRIVATE_KEY)
    }
  provisioner "file" {
    source      = "./modules/add-ons/add-on-shell/master_shell2.sh"
    destination = "/tmp/master_shell2.sh"
  }
  provisioner "file" {
    source      = "./modules/add-ons/add-on-yaml/calico.yaml"
    destination = "/tmp/calico.yaml"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_instance.node_master.public_ip
      user        = var.AWS_INSTANCE_USERNAME
      private_key = file(var.PATH_TO_PRIVATE_KEY)
    }
    inline = [
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