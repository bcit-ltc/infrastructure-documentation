#!/usr/bin/env bash
set -euo pipefail

# this runs each time the container starts

echo "=== post-start start ===" | tee -a "$HOME/status"

# Deploy k3d cluster
# echo "=== Creating k3d cluster with config ===" | tee -a "$HOME/status"
# k3d cluster create --config .devcontainer/k3d/k3d.yaml

# Confirm k3d cluster details
# kubectl cluster-info | tee -a "$HOME/status"
# echo "=== k3d cluster is ready ===" | tee -a "$HOME/status"

# Store the admin-user token for kubernetes-dashboard
# echo "=== storing kubernetes-dashboard admin-user token ===" | tee -a "$HOME/status"
# echo "$(kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d)" > "$HOME/dashboard-token.txt"

# Port-forward the kubernetes-dashboard service
# kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443 &

# Create `dashboard.sh` to print dashboard admin user token and proxy dashboard
# cat << 'EOF' > /usr/local/bin/dashboard
# #!/bin/bash

# # Retrieve token
# DASHBOARD_TOKEN=$(kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d)

# # Display token and port-forward dashboard
# echo -e "\n\nDashboard Token: $DASHBOARD_TOKEN\n\n"

# kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
# EOF

# chmod +x /usr/local/bin/dashboard

# echo "alias dashboard='/usr/local/bin/dashboard'" >> ~/.bashrc

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

# Ensure direnv is active for this session
direnv allow . || true

# Ensure shell hook is present
echo 'eval "$(direnv hook bash)"' >> "$HOME/.bashrc"

# Tweak bashrc
echo "alias l='ls -hAlF'" >> "$HOME/.bashrc"

# Create wrappers in .devcontainer/.direnv/bin
WRAP_DIR=".devcontainer/.direnv/bin"
mkdir -p "$WRAP_DIR"

# ---- Option A: short helper "sk" (your original intent) ----
# cat > "$WRAP_DIR/sk" <<'EOF'
# #!/usr/bin/env bash
# exec skaffold -f .devcontainer/skaffold/skaffold.yaml "$@"
# EOF
# chmod +x "$WRAP_DIR/sk"

# ---- Option B: a robust shadow wrapper called "skaffold"
# Behavior:
# - If user already provided a -f/--filename flag, pass through unchanged.
# - Else, inject -f .devcontainer/skaffold/skaffold.yaml
# - Avoid recursion by finding the first skaffold binary outside .direnv/bin.
cat > "$WRAP_DIR/skaffold" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# If user already set -f / --filename, don't inject our file
for arg in "$@"; do
  case "$arg" in
    -f|--filename) INCLUDES_FILE=1; break ;;
  esac
done
INCLUDES_FILE=${INCLUDES_FILE:-0}

# Find the real skaffold binary not in .direnv/bin
REAL=$(command -v -a skaffold | awk '!/\.direnv\/bin/ {print; exit}')
if [[ -z "${REAL:-}" ]]; then
  echo "Error: could not locate real 'skaffold' binary." >&2
  exit 127
fi

if [[ "$INCLUDES_FILE" -eq 1 ]]; then
  exec "$REAL" "$@"
else
  exec "$REAL" -f .devcontainer/skaffold/skaffold.yaml "$@"
fi
EOF
chmod +x "$WRAP_DIR/skaffold"

echo "=== post-start complete ===" | tee -a "$HOME/status"
