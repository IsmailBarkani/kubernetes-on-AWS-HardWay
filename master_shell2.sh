#!/bin/bash
export token=$1
echo $token

yum -y upgrade

echo "disable SELinux"
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

modprobe br_netfilter

echo "Firewalld install"
yum install firewalld -y
systemctl start firewalld
firewall-cmd --add-masquerade --permanent
firewall-cmd --reload

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system

swapoff -a

yum install docker -y 
systemctl start docker
systemctl enable docker

#Kubernetes installation

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

yum upgrade -y

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable kubelet
systemctl start kubelet

kubeadm config images pull

firewall-cmd --zone=public --permanent --add-port={6443,2379,2380,10250,10251,10252}/tcp
firewall-cmd --zone=public --permanent --add-rich-rule 'rule family=ipv4 source address=172.17.0.0/16 accept'
firewall-cmd --reload
kubeadm init --token=$token --pod-network-cidr 192.168.0.0/16 

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

kubectl taint nodes --all node-role.kubernetes.io/master-




