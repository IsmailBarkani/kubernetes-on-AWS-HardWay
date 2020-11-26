#!/bin/bash

sudo exec &> /var/log/init-aws-kubernetes-master.log

set -o verbose
set -o errexit
set -o pipefail

export KUBEADM_TOKEN=$1
export IP_ADDRESS=$2
echo $IP_ADDRESS
export CLUSTER_NAME=$3
export ASG_NAME=$4
export ASG_MIN_NODES=$5
export ASG_MAX_NODES=$6
export AWS_REGION=$7
export AWS_SUBNETS=$8
export KUBERNETES_VERSION="1.19.3"

# Set this only after setting the defaults
set -o nounset

# We needed to match the hostname expected by kubeadm an the hostname used by kubelet
FULL_HOSTNAME="$(curl -s http://169.254.169.254/latest/meta-data/hostname)"



# Install AWS CLI client
yum install -y epel-release
yum install -y python3-pip



# Install docker
yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
dnf  config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf -y list docker-ce
dnf -y install docker-ce --nobest

# Install Kubernetes components
sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# setenforce returns non zero if already SE Linux is already disabled
is_enforced=$(getenforce)
if [[ $is_enforced != "Disabled" ]]; then
  setenforce 0
  sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
  
fi
dnf upgrade -y

dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Start services
systemctl enable docker
systemctl start docker
systemctl enable kubelet
systemctl start kubelet

# Set settings needed by Docker
sysctl net.bridge.bridge-nf-call-iptables=1
sysctl net.bridge.bridge-nf-call-ip6tables=1

# Fix certificates file on CentOS
if cat /etc/*release | grep ^NAME= | grep CentOS ; then
    rm -rf /etc/ssl/certs/ca-certificates.crt/
    cp /etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
fi

# Initialize the master
cat >/tmp/kubeadm.yaml <<EOF
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
bootstrapTokens:
- token: $KUBEADM_TOKEN
  description: "kubeadm bootstrap token"
  ttl: "0s"
  usages:
  - authentication
  - signing
  groups:
  - system:bootstrappers:kubeadm:default-node-token
nodeRegistration:
  criSocket: "/var/run/dockershim.sock"
  taints:
  - effect: "NoSchedule"
    key: "node-role.kubernetes.io/master"
  kubeletExtraArgs:
    cloud-provider: "aws"
  ignorePreflightErrors:
  - IsPrivilegedUser
  name: $FULL_HOSTNAME
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
etcd:
  local:
    imageRepository: "k8s.gcr.io"
    imageTag: "3.2.24"
    dataDir: "/var/lib/etcd"
networking:
  serviceSubnet: "10.96.0.0/12"
  podSubnet: ""
  dnsDomain: "cluster.local"
kubernetesVersion: "v$KUBERNETES_VERSION"
apiServer:
  extraArgs:
    cloud-provider: "aws"
  certSANs:
  - "$IP_ADDRESS"
  timeoutForControlPlane: 6m0s
controllerManager:
  extraArgs:
    cloud-provider: "aws"
scheduler:
  extraArgs:
    cloud-provider: "aws"
certificatesDir: "/etc/kubernetes/pki"
imageRepository: "k8s.gcr.io"
clusterName: "kubernetes"
---
EOF
swapoff -a
kubeadm reset --force
kubeadm init --config /tmp/kubeadm.yaml --v=5

# Use the local kubectl config for further kubectl operations
export KUBECONFIG=/etc/kubernetes/admin.conf

# Install calico
kubectl apply -f /tmp/calico.yaml

# Allow the user to administer the cluster
kubectl create clusterrolebinding admin-cluster-binding --clusterrole=cluster-admin --user=admin

# Prepare the kubectl config file for download to client (IP address)
export KUBECONFIG_OUTPUT=/home/centos/kubeconfig_ip
kubeadm alpha kubeconfig user \
  --client-name admin \
  --apiserver-advertise-address $IP_ADDRESS \
  > $KUBECONFIG_OUTPUT
chown centos:centos $KUBECONFIG_OUTPUT
chmod 0600 $KUBECONFIG_OUTPUT

cp /home/centos/kubeconfig_ip /home/centos/kubeconfig
sed -i "s/server: https:\/\/$IP_ADDRESS:6443/server: https:\/\/nop:6443/g" /home/centos/kubeconfig
chown centos:centos /home/centos/kubeconfig
chmod 0600 /home/centos/kubeconfig
