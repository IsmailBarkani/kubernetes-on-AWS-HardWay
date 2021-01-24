variable "CLUSTER_NAME-nodes" {
  default = "kubernetes"
}
variable "INSTANCE_MASTER_TYPE" {
  type = string
}

variable "INSTANCE_WORKER_TYPE" {
  type = string
}

variable "AWS_AMI" {
  type = string
}

variable "KUBERNETES_VERSION" {
  default = "1.19.3"
}
variable "PATH_TO_PRIVATE_KEY" {
  type = string
}

variable "PATH_TO_PUBLIC_KEY" {
  type = string
}

variable "AWS_INSTANCE_USERNAME" {
  type = string
}

variable "K8S_TOKEN" {
  type = string
}

variable "MIN_ASG" {
  type = number
}

variable "MAX_ASG" {
  type = number
}

variable "CLUSTER_NAME" {
  default = "k8s-cluster"
}



