variable "AWS_ACCESS_KEY" {}

variable "AWS_SECRET_KEY" {}

variable "AWS_REGION" {
  default = "eu-west-3"
}

variable "AWS_AMI" {
  type = map
  default = {
    eu-west-3 = "ami-072ec828dae86abe5"
  }


}

variable "PATH_TO_PRIVATE_KEY" {
  default = "k8s-keypair"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "k8s-keypair.pub"
}

variable "AWS_INSTANCE_USERNAME" {
  default = "ubuntu"
}

variable "K8S_TOKEN" {
  default = "3cmj21.tvqzs75rnubmrk9s"
}

variable "MIN_ASG" {
  default = 3
}

variable "MAX_ASG" {
  default = 6
}

variable "CLUSTER_NAME" {
  default = "k8s-cluster"
}