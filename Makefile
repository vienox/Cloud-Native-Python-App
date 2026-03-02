# Makefile for Cloud Native Python App

.PHONY: help install test run docker-build docker-run clean

# Variables
PYTHON := python
PIP := pip
DOCKER_IMAGE := cloud-native-python-app
DOCKER_TAG := latest

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Install Python dependencies
	$(PIP) install -r requirements.txt

install-dev: ## Install development dependencies
	$(PIP) install -r requirements.txt
	$(PIP) install pytest pytest-cov httpx flake8 black isort

test: ## Run tests
	$(PYTHON) -m pytest tests/ -v

test-cov: ## Run tests with coverage
	$(PYTHON) -m pytest tests/ -v --cov=main --cov-report=html --cov-report=term

lint: ## Run code linting
	flake8 main.py --max-line-length=120
	black --check main.py
	isort --check-only main.py

format: ## Format code
	black main.py
	isort main.py

run: ## Run application locally
	$(PYTHON) main.py

docker-build: ## Build Docker image
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

docker-run: ## Run Docker container
	docker run -p 8000:8000 $(DOCKER_IMAGE):$(DOCKER_TAG)

docker-push: ## Push Docker image to registry
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)

k8s-apply: ## Apply Kubernetes manifests
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/deployment.yaml
	kubectl apply -f k8s/service.yaml

k8s-delete: ## Delete Kubernetes resources
	kubectl delete -f k8s/

k8s-logs: ## Show application logs from Kubernetes
	kubectl logs -l app=fastapi-app --tail=100 -f

terraform-init: ## Initialize Terraform
	cd terraform && terraform init

terraform-plan: ## Plan Terraform changes
	cd terraform && terraform plan

terraform-apply: ## Apply Terraform configuration
	cd terraform && terraform apply

terraform-destroy: ## Destroy Terraform infrastructure
	cd terraform && terraform destroy

clean: ## Clean up temporary files
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name '*.pyc' -delete
	find . -type f -name '*.pyo' -delete
	find . -type d -name '*.egg-info' -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name '.pytest_cache' -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name 'htmlcov' -exec rm -rf {} + 2>/dev/null || true
	rm -f .coverage

all: clean install test docker-build ## Run clean, install, test, and docker-build
