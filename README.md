
# Projet-SDTD-Scripts-Terraform-Infra

## Modèle d’arborescence de répertoires

La structure de fichiers pour notre module Terraform est comme ci-dessous:

- Répertoire Add-ons: contient des fichiers secondaires pour configurer et installer les prérequis de notre application (fichiers de politique .json, fichiers de configuration .sh, fichiers d'installation .yaml)
- Répertoire modules: contient tous les fichiers terraform nécessaire pour préparer notre infrastructure AWS (instances, asg, elb, vpc, security groupe ... )
- maint.tf:c'est le module principal. Il vous permettra de réutiliser le code terraform et de le maintenir d'une manière plus simple et rapide. En effet, il regroupe toutes les variables mentionnées dans les fichiers de configuration sous forme des arguments modifiables selon votre utilisation
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
1. - Modifier les credentials d'acces à AWS dans le fichier terraform.tfvars.
   - Ensuite, générer une paire de clés.
        >```ssh-keygen -f nom_cle```
   - Récupérer les chemins des clés générées et les mettre au niveau du fichier main.tf.
        >```PATH_TO_PRIVATE_KEY  = "chemin_cle_privee"```
        
        >```PATH_TO_PUBLIC_KEY  = "chemin_cle_public"```
        
2. Placez-vous au niveau du dossier qui contient le fichier maint.tf et lancez la commande suivante:
    >```terraform init```

    Cette commande permettra au Terraform d'initialiser le projet et de provisioner les plugins nécessaires.

3. Approvisionnement et déploiement automatique:
   - Lancez l'exécution des fichiers Terraform
   > ```terraform apply```

4. Connexion à l'instance master:
   - Récupérer l'adresse IP du master de AWS, puis lancer la connection ssh à cette instance
   > ```ssh -i cle_privee ec2-user@ip_master```
   - Récupérer l'adresse IP du master de AWS, puis lancer la connection ssh à cette instance
   > ```ssh -i cle_privee ec2-user@ip_master```

5. Lancement de l'application de traitement des données issue de l'api IMDB:
   - Tout d'abord, lancer le producer pour récupérer les données de l'api
     > ```kubectl exec -it deployment.apps/kafka-producer -- ./start-kafka-producer.sh```
   
   - Ouvrir un nouveau terminal et se connecter au master (étape 4), puis lancer Spark avec la commande suivante:
     > ```spark-submit  --master k8s://https://$K8S_HOST_IP:6443                                                                                                          --deploy-mode cluster                                                                                                                                                            --name kafka-sandbox                                                                                                                                                                                                                                                                          --class SparkNewsConsumer                                                                                                                                                  --conf spark.executor.instances=2                                                                                                                                  --conf "spark.driver.extraClassPath=/guava-19.0.jar"                                                                                                                                                                 --conf "spark.executor.extraClassPath=/guava-19.0.jar"                                                                                                                                                              --conf spark.kubernetes.driver.pod.name=spark-driver-pod                                                                                                                                                                                        --conf spark.kubernetes.container.image=youten/spark:6.2.1                                                                                                                                                                          local:///opt/Spark/target/Spark-1.0-SNAPSHOT-jar-with-dependencies.jar```
     
   - VISUALISATION:
