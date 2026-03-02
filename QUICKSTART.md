# Cloud Native Python App - Quick Start Guide

## ⚡ Quick Start (5 minut)

### Lokalny development

```bash
# 1. Zainstaluj zależności
pip install -r requirements.txt

# 2. Uruchom aplikację
python main.py

# 3. Otwórz w przeglądarce
# http://localhost:8000/docs
```

### Docker (lokalnie)

```bash
# Build
docker build -t myapp .

# Run
docker run -p 8000:8000 myapp

# Lub użyj docker-compose
docker-compose up
```

## 🚀 Deployment do AWS (krok po kroku)

### Przygotowanie (jednorazowo)

1. **Utwórz konto AWS**
   - Zarejestruj się na aws.amazon.com
   - Pobierz access keys (IAM)

2. **Skonfiguruj AWS CLI**
   ```bash
   aws configure
   # Podaj: Access Key, Secret Key, Region (eu-central-1)
   ```

3. **Wygeneruj SSH key**
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/cloud-native-key
   ```

4. **Utwórz konto Docker Hub**
   - hub.docker.com
   - Zapamiętaj username

### Deploy (30-60 minut pierwszym razem)

1. **Przygotuj Terraform variables**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   ```
   
   Edytuj `terraform.tfvars`:
   ```hcl
   ssh_public_key = "ssh-rsa AAA... (zawartość ~/.ssh/cloud-native-key.pub)"
   docker_username = "twoja-nazwa-dockerhub"
   ```

2. **Deploy infrastruktury**
   ```bash
   terraform init
   terraform apply
   # Wpisz: yes
   ```
   
   Zapisz SERVER_IP z outputu!

3. **Build i push Docker image**
   ```bash
   cd ..
   docker build -t TWOJA-NAZWA/cloud-native-python-app:latest .
   docker login
   docker push TWOJA-NAZWA/cloud-native-python-app:latest
   ```

4. **Poczekaj na inicjalizację K3s (2-3 minuty)**
   ```bash
   # Sprawdź czy gotowe
   ssh -i ~/.ssh/cloud-native-key ec2-user@SERVER_IP "kubectl get nodes"
   ```

5. **Deploy aplikacji**
   ```bash
   # Skopiuj manifesty
   scp -i ~/.ssh/cloud-native-key k8s/*.yaml ec2-user@SERVER_IP:~/k8s-manifests/
   
   # Deploy
   ssh -i ~/.ssh/cloud-native-key ec2-user@SERVER_IP
   cd ~/k8s-manifests
   sed -i 's/${DOCKER_IMAGE}/TWOJA-NAZWA\/cloud-native-python-app:latest/g' deployment.yaml
   kubectl apply -f namespace.yaml
   kubectl apply -f deployment.yaml
   kubectl apply -f service.yaml
   ```

6. **Test**
   ```bash
   curl http://SERVER_IP:30080/health
   # Otwórz: http://SERVER_IP:30080/docs
   ```

## 🔄 GitHub Actions CI/CD (automatyczny deploy)

1. **Fork/push repozytorium na GitHub**

2. **Dodaj Secrets w GitHub**
   Settings → Secrets and variables → Actions → New repository secret
   
   ```
   DOCKER_USERNAME = twoja-nazwa-dockerhub
   DOCKER_PASSWORD = token-dockerhub (nie hasło!)
   SSH_PRIVATE_KEY = zawartość ~/.ssh/cloud-native-key (cały plik)
   SSH_HOST = SERVER_IP (z terraform output)
   ```

3. **Push = auto deploy**
   ```bash
   git add .
   git commit -m "Auto deploy"
   git push
   ```

## 📊 Monitorowanie

```bash
# Logi aplikacji
ssh -i ~/.ssh/cloud-native-key ec2-user@SERVER_IP
kubectl logs -l app=fastapi-app -f

# Status deploymentu
kubectl get pods,svc

# K3s status
sudo systemctl status k3s
```

## 🧹 Sprzątanie

```bash
# Usuń aplikację z K8s
kubectl delete -f k8s/

# Zniszcz infrastrukturę AWS
cd terraform
terraform destroy
```

## ❓ Troubleshooting

**Problem:** Terraform apply fails
- **Rozwiązanie:** Sprawdź AWS credentials: `aws sts get-caller-identity`

**Problem:** Nie mogę się połączyć SSH
- **Rozwiązanie:** Sprawdź Security Group w AWS Console (czy port 22 otwarty)

**Problem:** K3s nie działa
- **Rozwiązanie:** 
  ```bash
  ssh ...
  sudo journalctl -u k3s -f
  sudo systemctl restart k3s
  ```

**Problem:** App nie odpowiada
- **Rozwiązanie:**
  ```bash
  kubectl get pods  # Sprawdź status
  kubectl describe pod POD_NAME  # Zobacz błędy
  kubectl logs POD_NAME  # Sprawdź logi
  ```

## 💡 Wskazówki

- **Oszczędzaj:** Zatrzymuj EC2 gdy nie używasz (restart wymaga ponownego deployu)
- **Bezpieczeństwo:** Zmień Security Group by ograniczyć dostęp do Twojego IP
- **Monitoring:** Dodaj CloudWatch dla lepszego monitoringu
- **Backup:** Zachowaj terraform.tfstate w bezpiecznym miejscu

## 🎯 Co pokazać na rozmowie

> "Za pomocą jednego polecenia `terraform apply` provisionuję całą infrastrukturę w AWS. Potem `git push` automatycznie testuje, buduje i wdraża nową wersję aplikacji na Kubernetes. Cały proces jest w pełni zautomatyzowany i powtarzalny."

Pokaż:
1. ✅ Działającą aplikację (http://SERVER_IP:30080/docs)
2. ✅ GitHub Actions pipeline (zielone checkmarki)
3. ✅ Kod Terraform (infrastructure as code)
4. ✅ Kubernetes manifests
5. ✅ Docker image na Docker Hub
