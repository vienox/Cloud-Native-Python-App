# Architecture Overview

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         DEVELOPER                                │
│                    (Local Development)                           │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 │ git push
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                      GITHUB REPOSITORY                           │
│  ┌────────────────────────────────────────────────────────┐     │
│  │  Source Code (main.py, Dockerfile, k8s/, terraform/)   │     │
│  └────────────────────────────────────────────────────────┘     │
└────┬────────────────────────────────────────────────────────────┘
     │ triggers
     ▼
┌─────────────────────────────────────────────────────────────────┐
│                    GITHUB ACTIONS CI/CD                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   TEST JOB   │  │  BUILD JOB   │  │ SECURITY JOB │          │
│  │  • pytest    │  │• docker build│  │  • Trivy     │          │
│  │  • flake8    │  │• docker push │  │  • SARIF     │          │
│  └──────────────┘  └──────┬───────┘  └──────────────┘          │
│                            │                                      │
│                     ┌──────▼─────────┐                          │
│                     │   DEPLOY JOB   │                          │
│                     │ • SSH to EC2   │                          │
│                     │ • kubectl apply│                          │
│                     └────────────────┘                          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ Docker Image
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DOCKER HUB                                 │
│  ┌────────────────────────────────────────────────────────┐     │
│  │  Container Registry                                     │     │
│  │  username/cloud-native-python-app:latest               │     │
│  └────────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────┘
                             │
                             │ kubectl apply
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        AWS CLOUD                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    VPC (10.0.0.0/16)                     │   │
│  │  ┌────────────────────────────────────────────────────┐  │   │
│  │  │          Public Subnet (10.0.1.0/24)               │  │   │
│  │  │  ┌──────────────────────────────────────────────┐  │  │   │
│  │  │  │   EC2 Instance (t3.medium)                   │  │  │   │
│  │  │  │   • Amazon Linux 2                           │  │  │   │
│  │  │  │   • Docker Engine                            │  │  │   │
│  │  │  │   • K3s Cluster                              │  │  │   │
│  │  │  │                                               │  │  │   │
│  │  │  │  ┌────────────────────────────────────────┐  │  │  │   │
│  │  │  │  │      Kubernetes (K3s)                  │  │  │  │   │
│  │  │  │  │                                         │  │  │  │   │
│  │  │  │  │  ┌──────────────────────────────────┐  │  │  │  │   │
│  │  │  │  │  │  Namespace: cloud-native-app     │  │  │  │  │   │
│  │  │  │  │  │                                   │  │  │  │  │   │
│  │  │  │  │  │  ┌────────────────────────────┐  │  │  │  │  │   │
│  │  │  │  │  │  │  Deployment: fastapi-app   │  │  │  │  │  │   │
│  │  │  │  │  │  │  Replicas: 2               │  │  │  │  │  │   │
│  │  │  │  │  │  │                             │  │  │  │  │  │   │
│  │  │  │  │  │  │  ┌──────────┐ ┌──────────┐ │  │  │  │  │  │   │
│  │  │  │  │  │  │  │  Pod 1   │ │  Pod 2   │ │  │  │  │  │  │   │
│  │  │  │  │  │  │  │ FastAPI  │ │ FastAPI  │ │  │  │  │  │  │   │
│  │  │  │  │  │  │  │  :8000   │ │  :8000   │ │  │  │  │  │  │   │
│  │  │  │  │  │  │  └──────────┘ └──────────┘ │  │  │  │  │  │   │
│  │  │  │  │  │  └────────────────────────────┘  │  │  │  │  │   │
│  │  │  │  │  │                                   │  │  │  │  │   │
│  │  │  │  │  │  ┌────────────────────────────┐  │  │  │  │  │   │
│  │  │  │  │  │  │  Service: fastapi-app      │  │  │  │  │  │   │
│  │  │  │  │  │  │  Type: NodePort             │  │  │  │  │  │   │
│  │  │  │  │  │  │  Port: 80 → 8000           │  │  │  │  │  │   │
│  │  │  │  │  │  │  NodePort: 30080           │  │  │  │  │  │   │
│  │  │  │  │  │  └────────────────────────────┘  │  │  │  │  │   │
│  │  │  │  │  └──────────────────────────────────┘  │  │  │  │   │
│  │  │  │  └────────────────────────────────────────┘  │  │  │   │
│  │  │  │                                               │  │  │   │
│  │  │  │  Elastic IP: XXX.XXX.XXX.XXX                 │  │  │   │
│  │  │  └──────────────────────────────────────────────┘  │  │   │
│  │  │                                                      │  │   │
│  │  │  ┌──────────────────────────────────────────────┐  │  │   │
│  │  │  │   Security Group                             │  │  │   │
│  │  │  │   • Port 22 (SSH)                            │  │  │   │
│  │  │  │   • Port 80 (HTTP)                           │  │  │   │
│  │  │  │   • Port 443 (HTTPS)                         │  │  │   │
│  │  │  │   • Port 6443 (K3s API)                      │  │  │   │
│  │  │  │   • Port 30000-32767 (NodePort)              │  │  │   │
│  │  │  └──────────────────────────────────────────────┘  │  │   │
│  │  └────────────────────────────────────────────────────┘  │   │
│  │                                                            │   │
│  │  ┌────────────────────────────────────────────────────┐  │   │
│  │  │          Internet Gateway                          │  │   │
│  │  └────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                             │
                             │ HTTP Request
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                       END USERS                                  │
│              http://SERVER_IP:30080                              │
│              http://SERVER_IP:30080/docs                         │
└─────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Application Layer (Python/FastAPI)

```
┌─────────────────────────────┐
│      FastAPI Application    │
├─────────────────────────────┤
│  • REST API Endpoints       │
│  • Pydantic Models          │
│  • In-memory Database       │
│  • Health Checks            │
│  • Auto-generated Docs      │
└─────────────────────────────┘
```

**Key Features:**
- RESTful API with CRUD operations
- Automatic OpenAPI/Swagger documentation
- Request/Response validation
- Health check endpoint for monitoring

### 2. Container Layer (Docker)

```
┌──────────────────────────────────┐
│     Docker Container Image       │
├──────────────────────────────────┤
│  Base: python:3.12-slim          │
│  • Python dependencies           │
│  • Application code              │
│  • Uvicorn ASGI server           │
│  • Health check configuration    │
│  Exposed Port: 8000              │
└──────────────────────────────────┘
```

**Features:**
- Multi-stage optimization
- Minimal base image
- Built-in health checks
- Non-root user execution

### 3. Orchestration Layer (Kubernetes/K3s)

```
┌──────────────────────────────────────┐
│      Kubernetes Resources            │
├──────────────────────────────────────┤
│  Namespace: cloud-native-app         │
│    ├─ Deployment                     │
│    │   └─ ReplicaSet (2 pods)        │
│    │       ├─ Pod 1 (FastAPI)        │
│    │       └─ Pod 2 (FastAPI)        │
│    └─ Service (NodePort)             │
│        └─ Load balancing             │
└──────────────────────────────────────┘
```

**Features:**
- High availability (2 replicas)
- Automatic restart on failure
- Rolling updates
- Health-based probes
- Load balancing

### 4. Infrastructure Layer (Terraform/AWS)

```
┌────────────────────────────────────────┐
│      AWS Infrastructure (IaC)          │
├────────────────────────────────────────┤
│  VPC                                   │
│    ├─ Subnet (Public)                  │
│    ├─ Internet Gateway                 │
│    ├─ Route Table                      │
│    └─ Security Group                   │
│                                         │
│  Compute                               │
│    ├─ EC2 Instance (t3.medium)         │
│    ├─ Elastic IP                       │
│    └─ SSH Key Pair                     │
│                                         │
│  Storage                               │
│    └─ EBS Volume (30GB)                │
└────────────────────────────────────────┘
```

**Provisioned via Terraform:**
- Repeatable infrastructure
- Version controlled
- Modular design
- Environment-specific configs

### 5. CI/CD Pipeline (GitHub Actions)

```
┌────────────────────────────────────────────────┐
│         CI/CD Workflow                         │
├────────────────────────────────────────────────┤
│  Trigger: Push to main                         │
│                                                 │
│  ┌──────────────┐                              │
│  │  Test Stage  │                              │
│  │  • pytest    │                              │
│  │  • flake8    │                              │
│  │  • coverage  │                              │
│  └──────┬───────┘                              │
│         │ ✓                                     │
│  ┌──────▼───────────┐                          │
│  │   Build Stage    │                          │
│  │  • Docker build  │                          │
│  │  • Tag image     │                          │
│  │  • Push to Hub   │                          │
│  └──────┬───────────┘                          │
│         │ ✓                                     │
│  ┌──────▼───────────┐                          │
│  │  Deploy Stage    │                          │
│  │  • SSH to EC2    │                          │
│  │  • kubectl apply │                          │
│  │  • Verify health │                          │
│  └──────────────────┘                          │
│                                                 │
│  ┌─────────────────────┐                       │
│  │  Security Scan      │                       │
│  │  • Trivy scanner    │                       │
│  │  • Upload to GitHub │                       │
│  └─────────────────────┘                       │
└────────────────────────────────────────────────┘
```

## Data Flow

### Request Flow
```
User Request
    ↓
Elastic IP (AWS)
    ↓
Security Group (Firewall)
    ↓
EC2 Instance
    ↓
NodePort Service (30080 → 80)
    ↓
Kubernetes Service (80 → 8000)
    ↓
Load Balancer
    ↓
Pod 1 or Pod 2 (FastAPI:8000)
    ↓
Response
```

### Deployment Flow
```
Code Change
    ↓
Git Push to GitHub
    ↓
GitHub Actions Triggered
    ↓
Run Tests
    ↓
Build Docker Image
    ↓
Push to Docker Hub
    ↓
SSH to EC2
    ↓
kubectl apply (Rolling Update)
    ↓
New Pods Created
    ↓
Health Checks Pass
    ↓
Old Pods Terminated
    ↓
Deployment Complete
```

## Network Diagram

```
Internet
    │
    │ HTTPS/SSH
    ▼
┌───────────────────────────┐
│   AWS Edge               │
│   (Internet Gateway)     │
└───────────┬───────────────┘
            │
            │
    ┌───────▼────────┐
    │  Elastic IP    │
    │ XXX.XXX.XXX.XX │
    └───────┬────────┘
            │
    ┌───────▼──────────────┐
    │  Security Group      │
    │  • SSH: 22          │
    │  • HTTP: 80         │
    │  • HTTPS: 443       │
    │  • K3s API: 6443    │
    │  • NodePort: 30080  │
    └───────┬──────────────┘
            │
    ┌───────▼─────────┐
    │  EC2 Instance   │
    │  10.0.1.X       │
    └───────┬─────────┘
            │
    ┌───────▼─────────┐
    │  K3s Network    │
    │  10.42.0.0/16   │
    └───────┬─────────┘
            │
    ┌───────▼─────────┐
    │  Service CIDR   │
    │  10.43.0.0/16   │
    └───────┬─────────┘
            │
    ┌───────▼─────────┐
    │  Pod Network    │
    │  Pod1: 10.42.X  │
    │  Pod2: 10.42.Y  │
    └─────────────────┘
```

## Technology Stack Matrix

| Layer | Technology | Purpose | Alternatives |
|-------|-----------|---------|--------------|
| **Language** | Python 3.12 | Application logic | Go, Node.js, Java |
| **Framework** | FastAPI | Web framework | Flask, Django |
| **Server** | Uvicorn | ASGI server | Gunicorn, Hypercorn |
| **Containerization** | Docker | Packaging | Podman, containerd |
| **Container Registry** | Docker Hub | Image storage | ECR, GCR, ACR |
| **Orchestration** | K3s | Container orchestration | K8s, Docker Swarm |
| **IaC** | Terraform | Infrastructure provisioning | CloudFormation, Pulumi |
| **Cloud Provider** | AWS | Infrastructure hosting | Azure, GCP |
| **Compute** | EC2 | Virtual machine | ECS, EKS, Fargate |
| **CI/CD** | GitHub Actions | Automation | GitLab CI, Jenkins |
| **VCS** | Git/GitHub | Version control | GitLab, Bitbucket |

## Security Architecture

```
┌─────────────────────────────────────────┐
│         Security Layers                 │
├─────────────────────────────────────────┤
│  1. Network Security                    │
│     • VPC Isolation                     │
│     • Security Groups (Firewall)        │
│     • Private Subnets (future)          │
│                                          │
│  2. Access Control                      │
│     • SSH Key Authentication            │
│     • IAM Roles & Policies              │
│     • GitHub Secrets Management         │
│                                          │
│  3. Container Security                  │
│     • Non-root User                     │
│     • Minimal Base Image                │
│     • Vulnerability Scanning (Trivy)    │
│                                          │
│  4. Application Security                │
│     • Input Validation (Pydantic)       │
│     • Health Checks                     │
│     • Resource Limits                   │
│                                          │
│  5. Monitoring & Logging                │
│     • Container Logs                    │
│     • K3s Audit Logs                    │
│     • CI/CD Pipeline Logs               │
└─────────────────────────────────────────┘
```

## Scalability Considerations

### Current Setup (Small Scale)
- 1 EC2 instance
- 2 pod replicas
- ~100-500 requests/second

### Medium Scale (Future)
- 3 EC2 instances (multi-node K3s)
- 5-10 pod replicas
- Load balancer (ALB/NLB)
- ~1000-5000 requests/second

### Large Scale (Cloud Native)
- Managed Kubernetes (EKS)
- Auto-scaling groups
- Database (RDS/DynamoDB)
- Caching (ElastiCache)
- CDN (CloudFront)
- ~10,000+ requests/second
