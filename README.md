
# Projet-SDTD-Scripts-Terraform-Infra

> fff

- dd

## Modèle d’arborescence de répertoires

La structure de fichiers pour notre module Terraform est comme ci-dessous:

- Répertoire Add-ons: contient des fichiers secondaires pour configurer et installer les prérequis de notre application (fichiers de politique .json, fichiers de configuration .sh, fichiers d'installation .yaml)
- Répertoire modules: contient tous les fichiers terraform nécessaire pour préparer notre infrastructure AWS (instances, asg, elb, vpc, security groupe ... )
- maint.tf: c'est le module principal. Il vous permettra de réutiliser le code terraform et de le maintenir d'une maniére plus simple et rapide. En effet,  il regroupe toutes les variables mentionnées dans les fichiers de configuration sous forme des arguments modifiable selon votre utilisation
- terraform.tf: contient les informations d'identification à votre compte AWS (ACCESS_KEY, SECRET_KEY) .
```
├── Projet-SDTD-Infrastructure
│   ├── modules
│   │   ├── add-ons
│   │   │   ├── add-ons-policy
│   │   │   │   ├── master-policy.json
│   │   │   │   └── node-policy.json
│   │   │   ├── add-ons-shell
│   │   │   │   ├── master_shell.sh
│   │   │   │   └── node_shell.sh
│   │   │   └── add-ons-yaml
│   │   │       ├── cassandra-cluster.yaml
│   │   │       ├── client.yaml
│   │   │       ├── kafka-cluster.yaml
│   │   │       ├── kafka-service.yaml
│   │   │       ├── zookeeper-cluster.yaml
│   │   │       └── zookeeper-service.yaml
│   │   ├── kypair
│   │   ├── keypair.pub
│   │   ├── main-asg-policy.tf
│   │   ├── main-asg.tf
│   │   ├── main-elb
│   │   ├── main-iam.tf
│   │   ├── main-vpc.tf
│   │   ├── main-master.tf
│   │   ├── security-group.tf
│   │   └── variables.tf
│   ├── main.tf
│   ├── terraform.tfvars
│   ├── README.md
└── └── outputs.tf
```
## Cas d'utilisation
1. Placez vous au niveau du dossier qui contient le fichier maint.tf et lancez la commande suivante:
    >```terraform init```

    Cette commande permettra au Terraform d'initialiser le projet et de provisioner les plugins nécessaire.

2. Lancez l'exécution des fichiers Terraform:
   > ```terraform apply```

3. 