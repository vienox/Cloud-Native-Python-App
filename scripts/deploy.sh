#!/bin/bash

# Quick deployment script for Cloud Native Python App
# Usage: ./deploy.sh

set -e

echo "🚀 Cloud Native Python App - Quick Deploy Script"
echo "================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if required tools are installed
check_requirements() {
    echo -e "${YELLOW}Checking requirements...${NC}"
    
    command -v terraform >/dev/null 2>&1 || { echo -e "${RED}Terraform is not installed${NC}"; exit 1; }
    command -v docker >/dev/null 2>&1 || { echo -e "${RED}Docker is not installed${NC}"; exit 1; }
    command -v aws >/dev/null 2>&1 || { echo -e "${RED}AWS CLI is not installed${NC}"; exit 1; }
    
    echo -e "${GREEN}✓ All requirements met${NC}"
}

# Build and push Docker image
build_docker() {
    echo -e "${YELLOW}Building Docker image...${NC}"
    
    read -p "Enter your Docker Hub username: " DOCKER_USER
    IMAGE_NAME="$DOCKER_USER/cloud-native-python-app:latest"
    
    docker build -t $IMAGE_NAME .
    
    read -p "Push to Docker Hub? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker login
        docker push $IMAGE_NAME
        echo -e "${GREEN}✓ Image pushed to Docker Hub${NC}"
    fi
}

# Deploy infrastructure
deploy_infrastructure() {
    echo -e "${YELLOW}Deploying infrastructure with Terraform...${NC}"
    
    cd terraform
    
    if [ ! -f "terraform.tfvars" ]; then
        echo -e "${RED}terraform.tfvars not found!${NC}"
        echo "Please create terraform.tfvars based on terraform.tfvars.example"
        exit 1
    fi
    
    terraform init
    terraform plan
    
    read -p "Apply Terraform configuration? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform apply -auto-approve
        echo -e "${GREEN}✓ Infrastructure deployed${NC}"
        
        # Get server IP
        SERVER_IP=$(terraform output -raw instance_public_ip)
        echo -e "${GREEN}Server IP: $SERVER_IP${NC}"
        echo "Waiting for K3s to initialize (2 minutes)..."
        sleep 120
    fi
    
    cd ..
}

# Deploy to Kubernetes
deploy_app() {
    echo -e "${YELLOW}Deploying application to Kubernetes...${NC}"
    
    if [ -z "$SERVER_IP" ]; then
        cd terraform
        SERVER_IP=$(terraform output -raw instance_public_ip)
        cd ..
    fi
    
    read -p "Enter Docker image name (e.g., username/cloud-native-python-app:latest): " DOCKER_IMAGE
    
    # Copy manifests and deploy
    ssh -o StrictHostKeyChecking=no ec2-user@$SERVER_IP "mkdir -p ~/k8s-manifests"
    scp k8s/*.yaml ec2-user@$SERVER_IP:~/k8s-manifests/
    
    # Update deployment with actual image
    ssh ec2-user@$SERVER_IP << EOF
        cd ~/k8s-manifests
        sed -i 's|\${DOCKER_IMAGE}|$DOCKER_IMAGE|g' deployment.yaml
        kubectl apply -f namespace.yaml
        kubectl apply -f deployment.yaml
        kubectl apply -f service.yaml
        echo "Waiting for rollout..."
        kubectl rollout status deployment/fastapi-app --timeout=300s
        kubectl get pods,svc
EOF
    
    echo -e "${GREEN}✓ Application deployed${NC}"
    echo -e "${GREEN}Access your app at: http://$SERVER_IP:30080${NC}"
    echo -e "${GREEN}API docs at: http://$SERVER_IP:30080/docs${NC}"
}

# Test deployment
test_deployment() {
    echo -e "${YELLOW}Testing deployment...${NC}"
    
    if [ -z "$SERVER_IP" ]; then
        cd terraform
        SERVER_IP=$(terraform output -raw instance_public_ip)
        cd ..
    fi
    
    sleep 10
    
    echo "Testing health endpoint..."
    curl -f http://$SERVER_IP:30080/health || echo "Health check failed"
    
    echo "Testing root endpoint..."
    curl -f http://$SERVER_IP:30080/ || echo "Root endpoint failed"
    
    echo -e "${GREEN}✓ Deployment test complete${NC}"
}

# Main menu
main() {
    check_requirements
    
    echo ""
    echo "Select deployment option:"
    echo "1) Full deployment (Docker + Terraform + K8s)"
    echo "2) Build and push Docker image only"
    echo "3) Deploy infrastructure only (Terraform)"
    echo "4) Deploy application to existing cluster"
    echo "5) Test deployment"
    echo "6) Exit"
    
    read -p "Enter option (1-6): " option
    
    case $option in
        1)
            build_docker
            deploy_infrastructure
            deploy_app
            test_deployment
            ;;
        2)
            build_docker
            ;;
        3)
            deploy_infrastructure
            ;;
        4)
            deploy_app
            ;;
        5)
            test_deployment
            ;;
        6)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}🎉 Deployment script completed!${NC}"
}

main
