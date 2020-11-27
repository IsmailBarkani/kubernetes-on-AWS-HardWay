variable "AWS_ACCESS_KEY" {}

variable "AWS_SECRET_KEY" {}

variable "AWS_REGION" {
  default = "eu-west-3"
}

variable "CLUSTER_NAME-nodes" {
  default = "kubernetes"
}
variable "AWS_AMI" {
  type = map
  default = {
    eu-west-3 = "ami-08df9719b135f181d"
  }

}

variable "KUBERNETES_VERSION" {
  default = "1.19.3"
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
  default = "4hznti.qpq36r5l1jggsm6t"
}

variable "MIN_ASG" {
  default = 1
}

variable "MAX_ASG" {
  default = 3
}

variable "CLUSTER_NAME" {
  default = "k8s-cluster"
}