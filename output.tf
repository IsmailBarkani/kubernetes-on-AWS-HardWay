output "IPv4_Public_Master" {
  value = module.main-module.IPv4_Public_Master
}

output "IPv4_Privée_Master" {
  value = module.main-module.IPv4_Privée_Master
}

output "Username" {
  value = "ec2-user"
}

output "DNS_ELB" {
  value = module.main-module.DNS_ELB
}