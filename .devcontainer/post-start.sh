#!/bin/bash

# this runs each time the container starts

echo "=== $(date +'%Y-%m-%d %H:%M:%S') post-start start ===" | tee -a "$HOME/status"

# Mount k3d/kubernetes-dashboard for automatic deployment

# Deploy k3d cluster
echo "=== $(date +'%Y-%m-%d %H:%M:%S') Creating k3d cluster with config ===" | tee -a "$HOME/status"
k3d cluster create --config .devcontainer/k3d/k3d.yaml

# Confirm k3d cluster details
kubectl cluster-info | tee -a "$HOME/status"
echo "=== $(date +'%Y-%m-%d %H:%M:%S') k3d cluster is ready ===" | tee -a "$HOME/status"

# echo "=== Building app Docker image ==="
# docker build -t k3d-localregistry.localhost:5000/myapp:latest .

# echo "=== Pushing image to local registry ==="
# docker push k3d-localregistry.localhost:5000/myapp:latest

# echo "=== Cloning only the infrastructure-documentation Helm chart ==="
# git clone --filter=blob:none --sparse https://github.com/bcit-ltc/helm-charts.git /tmp/helm-charts
# cd /tmp/helm-charts
# git sparse-checkout set apps/infrastructure-documentation
# cd -

# echo "=== Deploying app with Helm ==="
# helm upgrade --install myapp oci://ghcr.io/bcit-ltc/oci/infrastructure-documentation \
#   --reuse-values \
#   --set image.repository=registry.localhost:5000/myapp \
#   --set image.tag=latest

#   --set service.type=LoadBalancer \
#   --set containerPort=8080

# helm upgrade --install myapp /tmp/helm-charts/apps/infrastructure-documentation \
#   --set image.repository=k3d-localregistry.localhost:5000/myapp \
#   --set image.tag=latest \
#   --set service.type=LoadBalancer \
#   --set containerPort=8080

echo "=== $(date +'%Y-%m-%d %H:%M:%S') post-start complete ===" | tee -a "$HOME/status"

# Return to workspace
cd $CODESPACE_VSCODE_FOLDER
