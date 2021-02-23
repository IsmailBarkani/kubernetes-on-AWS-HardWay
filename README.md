# kubernetes-on-AWS-HardWay
[![Terraform](https://img.shields.io/static/v1?label=Terraform&message=v0.12.25&color=blueviolet&logo=Terraform)](https://www.terraform.io/downloads.html)
[![AWS](https://img.shields.io/static/v1?label=AWS-CLI&message=v1.18.60&color=orange&logo=amazon)](https://aws.amazon.com/fr/cli/)

Provisioning Kubernetes clusters on AWS with Terraform.

:white_check_mark: 1. deploy Kubernetes on single node

:white_check_mark: 2. deploy Kubernetes in multi node

:white_check_mark: 3. deploy Kubernetes in multi node (automated)

:white_check_mark: 4. define the role of each AWS component

:white_check_mark: 5. interconnection of nodes & security aspects

:white_check_mark: 6. interconnection of nodes & security aspects (automated)

:white_check_mark: 7. autoscale nodes & balance network load

:white_check_mark: 8. autoscale nodes & balance network load (automated)

:white_check_mark: 9. Performance Test (ELB, ASG)



 - **Save your AWS access key in a .tfvars file (never share a .tfvars file)**

```
AWS_ACCESS_KEY="XXXXXYY"
AWS_SECRET_KEY="YYYYXXXXXXXX"
```

- **Initialize your working directory**

```
$ terraform init
```

- **Apply**

```
$ terraform apply
```
