# ☁️ Cloud Native Python Application - Full DevOps Pipeline

[![CI/CD Pipeline](https://github.com/yourusername/cloud-native-python-app/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/yourusername/cloud-native-python-app/actions)
[![Python 3.12](https://img.shields.io/badge/python-3.12-blue.svg)](https://www.python.org/downloads/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115+-green.svg)](https://fastapi.tiangolo.com/)
[![Docker](https://img.shields.io/badge/docker-ready-blue.svg)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-ready-blue.svg)](https://kubernetes.io/)
[![Terraform](https://img.shields.io/badge/terraform-IaC-purple.svg)](https://www.terraform.io/)

> **Kompleksowy projekt DevOps** demonstrując pełny cykl rozwoju aplikacji cloud-native z wykorzystaniem najnowszych praktyk i narzędzi.

## 🎯 O projekcie

Aplikacja w Pythonie (FastAPI) z pełną infrastrukturą DevOps obejmującą:
- **Konteneryzację** (Docker)
- **Orkiestrację** (Kubernetes/K3s)
- **Infrastructure as Code** (Terraform)
- **CI/CD Pipeline** (GitHub Actions)
- **Cloud Deployment** (AWS EC2)
- **Automated Testing** & Security Scanning

## 🏗️ Architektura

```
┌─────────────┐
│  Git Push   │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────┐
│      GitHub Actions CI/CD       │
│  ┌──────────┬─────────────────┐ │
│  │  Test    │  Build & Push   │ │
│  │  Python  │  Docker Image   │ │
│  └──────────┴─────────────────┘ │
└──────────────┬──────────────────┘
               │
               ▼
┌──────────────────────────────────┐
│      Terraform (AWS)             │
│  ┌────────────────────────────┐  │
│  │  EC2 + VPC + Security      │  │
│  │  K3s Installation          │  │
│  └────────────────────────────┘  │
└──────────────┬───────────────────┘
               │
               ▼
┌──────────────────────────────────┐
│    Kubernetes Cluster (K3s)      │
│  ┌────────────────────────────┐  │
│  │  Deployment (2 replicas)   │  │
│  │  Service (NodePort)        │  │
│  │  Health Checks             │  │
│  └────────────────────────────┘  │
└──────────────┬───────────────────┘
               │
               ▼
       ┌──────────────┐
       │  Running App │
       │  Port 30080  │
       └──────────────┘
```

## 🚀 Technologie

| Kategoria | Technologia | Zastosowanie |
|-----------|-------------|--------------|
| **Application** | Python 3.12, FastAPI | REST API Backend |
| **Containerization** | Docker, Docker Compose | Pakowanie aplikacji |
| **Orchestration** | Kubernetes (K3s) | Zarządzanie kontenerami |
| **Infrastructure** | Terraform, AWS EC2 | Infrastructure as Code |
| **CI/CD** | GitHub Actions | Automatyzacja deploymentu |
| **Operating System** | Amazon Linux 2 | Środowisko produkcyjne |
| **Security** | Trivy Scanner | Skanowanie podatności |

## 📁 Struktura projektu

```
cloud-native-python-app/
├── .github/
│   └── workflows/
│       └── ci-cd.yml           # GitHub Actions pipeline
├── k8s/
│   ├── deployment.yaml         # Kubernetes Deployment
│   ├── service.yaml            # Kubernetes Service
│   └── namespace.yaml          # Kubernetes Namespace
├── terraform/
│   ├── main.tf                 # Main infrastructure
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   ├── user-data.sh            # EC2 initialization script
│   └── terraform.tfvars.example # Example variables
├── tests/
│   └── test_main.py            # Unit tests
├── main.py                     # FastAPI application
├── requirements.txt            # Python dependencies
├── Dockerfile                  # Docker image definition
├── .dockerignore               # Docker ignore patterns
├── .gitignore                  # Git ignore patterns
└── README.md                   # This file
```

## 🔧 Wymagania wstępne

### Lokalne narzędzia:
- **Python 3.12+**
- **Docker Desktop**
- **Terraform >= 1.0**
- **AWS CLI** (skonfigurowane z credentials)
- **Git**
- **SSH client**

### Konta:
- **AWS Account** (Free Tier wystarczy)
- **Docker Hub Account**
- **GitHub Account**

## 📖 Przewodnik wdrożenia

### 1️⃣ Konfiguracja lokalna

```bash
# Sklonuj repozytorium
git clone https://github.com/yourusername/cloud-native-python-app.git
cd cloud-native-python-app

# Utwórz wirtualne środowisko Python
python -m venv .venv
.venv\Scripts\activate  # Windows
# source .venv/bin/activate  # Linux/Mac

# Zainstaluj zależności
pip install -r requirements.txt

# Uruchom aplikację lokalnie
python main.py
# Aplikacja dostępna: http://localhost:8000
# Swagger UI: http://localhost:8000/docs
```

### 2️⃣ Test Docker lokalnie

```bash
# Zbuduj obraz Docker
docker build -t cloud-native-python-app .

# Uruchom kontener
docker run -p 8000:8000 cloud-native-python-app

# Test API
curl http://localhost:8000/health
```

### 3️⃣ Wdrożenie infrastruktury z Terraform

```bash
cd terraform

# Wygeneruj klucz SSH (jeśli nie masz)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/cloud-native-key

# Skopiuj przykładowy plik zmiennych
cp terraform.tfvars.example terraform.tfvars

# Edytuj terraform.tfvars - dodaj swój publiczny klucz SSH
# ssh_public_key = "ssh-rsa AAAA... your-key-here"

# Skonfiguruj AWS credentials
aws configure

# Inicjalizuj Terraform
terraform init

# Sprawdź plan
terraform plan

# Wdróż infrastrukturę (utworzy EC2 z K3s)
terraform apply

# Zapisz output - znajdziesz tam IP serwera i komendy SSH
terraform output
```

**Ważne:** Proces inicjalizacji K3s na EC2 zajmuje ~2-3 minuty po utworzeniu instancji.

### 4️⃣ Weryfikacja K3s

```bash
# Pobierz IP z Terraform output
export SERVER_IP=$(terraform output -raw instance_public_ip)

# Połącz się SSH
ssh -i ~/.ssh/cloud-native-key ec2-user@$SERVER_IP

# Na serwerze sprawdź K3s
kubectl get nodes
kubectl get pods --all-namespaces
```

### 5️⃣ Konfiguracja GitHub Secrets

W repozytorium GitHub ustaw następujące Secrets (Settings → Secrets and variables → Actions):

```
DOCKER_USERNAME      # Twoja nazwa użytkownika Docker Hub
DOCKER_PASSWORD      # Token Docker Hub
SSH_PRIVATE_KEY      # Zawartość ~/.ssh/cloud-native-key
SSH_HOST             # IP serwera EC2 (z terraform output)
```

**Jak utworzyć Docker Hub token:**
1. Zaloguj się na Docker Hub
2. Account Settings → Security → New Access Token
3. Skopiuj token

### 6️⃣ Deploy przez CI/CD

```bash
# Push do repozytorium GitHub uruchomi automatyczny deployment
git add .
git commit -m "Initial deployment"
git push origin main

# Monitoruj pipeline w GitHub Actions
# https://github.com/yourusername/cloud-native-python-app/actions
```

### 7️⃣ Weryfikacja aplikacji

```bash
# Aplikacja dostępna na porcie 30080
curl http://$SERVER_IP:30080/
curl http://$SERVER_IP:30080/health
curl http://$SERVER_IP:30080/items

# Lub otwórz w przeglądarce:
# http://<SERVER_IP>:30080/docs
```

## 🧪 Testowanie

```bash
# Uruchom testy jednostkowe
pip install pytest pytest-cov httpx
pytest tests/ -v

# Test z coverage
pytest tests/ --cov=main --cov-report=html

# Otwórz raport coverage
# htmlcov/index.html
```

## 📊 CI/CD Pipeline

Pipeline składa się z 4 jobów:

### 1. **Test** 
- Instaluje zależności Python
- Uruchamia testy jednostkowe
- Sprawdza jakość kodu (flake8)

### 2. **Build**
- Buduje obraz Docker
- Pushuje do Docker Hub z tagiem `latest` i SHA commit
- Cache optymalizacja dla szybszych buildów

### 3. **Deploy**
- Kopiuje manifesty Kubernetes na serwer
- Aktualizuje deployment z nowym obrazem
- Rollout i weryfikacja

### 4. **Security Scan**
- Skanuje kod z Trivy
- Upload wyników do GitHub Security

## 🛡️ Security Best Practices

✅ **Zaimplementowane:**
- Secret management przez GitHub Secrets
- Security groups z minimalnym dostępem
- Health checks w Kubernetes
- Vulnerability scanning (Trivy)
- SSH key-based authentication
- Non-root user w kontenerze

## 🔄 Częste operacje

### Aktualizacja aplikacji
```bash
# Zmień kod w main.py
git add main.py
git commit -m "Update application logic"
git push origin main
# Pipeline automatycznie wdroży nową wersję
```

### Skalowanie aplikacji
```bash
# Edytuj k8s/deployment.yaml
# Zmień replicas: 2 na replicas: 5
kubectl apply -f k8s/deployment.yaml
```

### Podgląd logów
```bash
ssh ec2-user@$SERVER_IP
kubectl logs -l app=fastapi-app --tail=100 -f
```

### Rollback deployment
```bash
kubectl rollout undo deployment/fastapi-app
```

## 💰 Koszty AWS

Szacunkowe koszty (region eu-central-1):
- **t3.medium EC2:** ~$30/miesiąc (730h × $0.0416/h)
- **EBS 30GB:** ~$3/miesiąc
- **Elastic IP:** Darmowe (gdy przypisane do działającej instancji)
- **Data transfer:** Uzależnione od użycia

**💡 Tip:** Użyj t3a.medium (~20% taniej) lub zatrzymuj instancję gdy nie jest używana.

## 🧹 Cleanup

```bash
# Usuń deployment z Kubernetes
kubectl delete -f k8s/

# Zniszcz infrastrukturę AWS
cd terraform
terraform destroy

# Usuń obrazy Docker (opcjonalnie)
docker rmi cloud-native-python-app
```

## 📝 API Endpoints

| Metoda | Endpoint | Opis |
|--------|----------|------|
| GET | `/` | Welcome message |
| GET | `/health` | Health check |
| GET | `/items` | Pobierz wszystkie items |
| GET | `/items/{id}` | Pobierz item po ID |
| POST | `/items` | Utwórz nowy item |
| PUT | `/items/{id}` | Aktualizuj item |
| DELETE | `/items/{id}` | Usuń item |
| GET | `/docs` | Swagger UI |
| GET | `/redoc` | ReDoc documentation |

### Przykładowe requesty

```bash
# Create item
curl -X POST http://$SERVER_IP:30080/items \
  -H "Content-Type: application/json" \
  -d '{"name":"Laptop","description":"Gaming laptop","price":1299.99,"in_stock":true}'

# Get all items
curl http://$SERVER_IP:30080/items

# Get specific item
curl http://$SERVER_IP:30080/items/1

# Update item
curl -X PUT http://$SERVER_IP:30080/items/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Laptop Pro","price":1499.99,"in_stock":true}'

# Delete item
curl -X DELETE http://$SERVER_IP:30080/items/1
```

## 🎤 Co powiedzieć na rozmowie o pracę

> *"Stworzyłem aplikację REST API w Pythonie wykorzystując FastAPI, którą skonteryzowałem z użyciem Docker. Całą infrastrukturę w AWS provisionowałem przez Terraform - EC2, VPC, Security Groups. Na serwerze uruchomiłem lekki klaster Kubernetes (K3s) zamiast pełnego EKS, co jest bardziej cost-effective dla prostych projektów.*
>
> *Następnie zbudowałem pipeline CI/CD w GitHub Actions, który automatycznie:*
> - *testuje kod*
> - *buduje i publikuje obraz Docker*
> - *wdraża aplikację na Kubernetes*
> - *wykonuje security scanning*
>
> *Cały proces od git push do działającej aplikacji jest w pełni zautomatyzowany. Używam health checks, wielokrotnych replik dla wysokiej dostępności, i NodePort service dla łatwego dostępu.*
>
> *Projekt pokazuje praktyczne wykorzystanie: Python, Docker, Kubernetes, Terraform, CI/CD, Linux i AWS - czyli pełnego DevOps stack."*

## 🔗 Przydatne linki

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [K3s - Lightweight Kubernetes](https://k3s.io/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## 📧 Kontakt & Wsparcie

W razie problemów:
1. Sprawdź GitHub Actions logs
2. Sprawdź Terraform output
3. Sprawdź logi K3s: `sudo journalctl -u k3s -f`
4. Sprawdź logi aplikacji: `kubectl logs -l app=fastapi-app`

## 📜 Licencja

MIT License - użyj projektu jak chcesz!

---

**⭐ Jeśli projekt Ci pomógł, zostaw gwiazdkę na GitHub!**

**🚀 Powodzenia na rozmowie rekrutacyjnej!**
