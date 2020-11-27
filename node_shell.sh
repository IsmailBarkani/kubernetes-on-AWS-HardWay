#!/bin/bash

export master_ip=${master_private_ip}
echo $master_ip
export token=${kubeadm_token}
echo 
cat <<EOF > /tmp/test.txt
hey bro 
EOF
dnf -y upgrade

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

dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf -y install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm
dnf install docker-ce --nobest -y
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

dnf upgrade -y

dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable kubelet
systemctl start kubelet

firewall-cmd --zone=public --permanent --add-port={10250,30000-32767}/tcp
firewall-cmd --reload

kubeadm join $master_ip:6443 --token $token --discovery-token-unsafe-skip-ca-verification --ignore-preflight-errors all



