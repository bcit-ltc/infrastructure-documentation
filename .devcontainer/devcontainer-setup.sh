#!/bin/sh
set -e

echo "=== Checking k3d installation ==="
k3d --version || { echo "k3d not found!"; exit 1; }

echo "=== Checking Docker installation ==="
docker --version || { echo "Docker not found!"; exit 1; }

echo "=== Creating k3d registry (if not exists) ==="
k3d registry create localregistry.localhost --port 5000 || true

echo "=== Creating k3d cluster with registry and port 8080 mapping (if not exists) ==="
k3d cluster create mycluster --registry-use k3d-localregistry.localhost:5000 --port "8080:80@loadbalancer" || true

echo "=== Building app Docker image ==="
docker build -t k3d-localregistry.localhost:5000/myapp:latest .

echo "=== Pushing image to local registry ==="
docker push k3d-localregistry.localhost:5000/myapp:latest

echo "=== Cloning only the infrastructure-documentation Helm chart ==="
git clone --filter=blob:none --sparse https://github.com/bcit-ltc/helm-charts.git /tmp/helm-charts
cd /tmp/helm-charts
git sparse-checkout set apps/infrastructure-documentation
cd -

echo "=== Deploying app with Helm ==="
helm upgrade --install myapp /tmp/helm-charts/apps/infrastructure-documentation \
  --set image.repository=k3d-localregistry.localhost:5000/myapp \
  --set image.tag=latest \
  --set service.type=LoadBalancer

echo "=== Setup complete ==="