
#AAA
variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {}

#AAA
provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  #token = var.aws_session_token
  region     = var.AWS_REGION
}


module "main-module" {
    source = "./modules"

    #AAA
    INSTANCE_MASTER_TYPE = "t2.xlarge"

    #AAA
    INSTANCE_WORKER_TYPE = "t2.xlarge"

    #AAA
    AWS_AMI = "ami-0be2609ba883822ec" 

    #AAA
    PATH_TO_PRIVATE_KEY  = "./k8s-keypair"

    #AAA
    PATH_TO_PUBLIC_KEY  = "./k8s-keypair.pub"

    #AAA
    AWS_INSTANCE_USERNAME = "ec2-user"

    #AAA
    K8S_TOKEN = "4hznti.qpq36r5l1jggsm6t"

    #AAA
    MIN_ASG = 1

    #AAA
    MAX_ASG = 3
    
}