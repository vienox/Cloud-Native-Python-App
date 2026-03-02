#!/bin/bash
set -e

# Update system
yum update -y

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install K3s
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644

# Wait for K3s to be ready
sleep 30

# Configure kubectl access for ec2-user
mkdir -p /home/ec2-user/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/.kube/config
chown -R ec2-user:ec2-user /home/ec2-user/.kube
chmod 600 /home/ec2-user/.kube/config

# Install kubectl (if not already available)
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
fi

# Create deployment directory
mkdir -p /home/ec2-user/k8s-manifests
chown -R ec2-user:ec2-user /home/ec2-user/k8s-manifests

# Enable and start firewalld (optional, but recommended for security)
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --reload || true

# Create status file
echo "K3s installation completed at $(date)" > /home/ec2-user/k3s-ready.txt
