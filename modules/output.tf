output "IPv4_Public_Master" {
  value = aws_eip.master.public_ip
}

output "IPv4_Privée_Master" {
  value = aws_instance.node_master.private_ip
}

output "Username" {
  value = "ec2-user"
}

output "DNS_ELB" {
  value = aws_lb.my-elb.dns_name
}