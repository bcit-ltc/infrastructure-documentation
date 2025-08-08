#!/bin/bash

# this runs each time the container starts

echo "=== post-start start ==="
# echo "$(date +'%Y-%m-%d %H:%M:%S')    post-start start" >> "$HOME/status"

# update the base docker images
# docker pull mcr.microsoft.com/dotnet/aspnet:6.0-alpine
# docker pull mcr.microsoft.com/dotnet/sdk:6.0
# docker pull ghcr.io/cse-labs/webv-red:latest

echo "=== Building app Docker image ==="
docker build -t k3d-localregistry.localhost:5000/myapp:latest .

echo "=== Pushing image to local registry ==="
docker push k3d-localregistry.localhost:5000/myapp:latest

# echo "=== Cloning only the infrastructure-documentation Helm chart ==="
# git clone --filter=blob:none --sparse https://github.com/bcit-ltc/helm-charts.git /tmp/helm-charts
# cd /tmp/helm-charts
# git sparse-checkout set apps/infrastructure-documentation
# cd -

echo "=== Deploying app with Helm ==="
helm upgrade --install myapp oci://ghcr.io/bcit-ltc/oci/infrastructure-documentation \
  --reuse-values \
  --set image.repository=registry.localhost:5000/myapp \
  --set image.tag=latest

#   --set service.type=LoadBalancer \
#   --set containerPort=8080

# helm upgrade --install myapp /tmp/helm-charts/apps/infrastructure-documentation \
#   --set image.repository=k3d-localregistry.localhost:5000/myapp \
#   --set image.tag=latest \
#   --set service.type=LoadBalancer \
#   --set containerPort=8080

echo "=== post-start complete ==="

# echo "$(date +'%Y-%m-%d %H:%M:%S')    post-start complete" >> "$HOME/status"
