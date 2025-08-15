#!/usr/bin/env bash
set -euo pipefail

# Load shared env next to this script, even if called via a relative path or symlink
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=/dev/null
. "$SCRIPT_DIR/env.sh"

mkdir -p "$APP_STATE_DIR"

echo "🚀 Creating k3d cluster..."
k3d cluster create --config "$K3D_CFG_PATH"

echo -e "\n📡 Fetching cluster info...\n"
kubectl cluster-info | tee -a "$HOME/status"

echo -e "\n⏳ Waiting for Kubernetes Dashboard to become ready...\n"
kubectl wait --for=condition=available --timeout=120s deployment/kubernetes-dashboard -n kubernetes-dashboard || true
until kubectl get secret admin-user -n kubernetes-dashboard >/dev/null 2>&1; do
  echo "   ...still waiting for admin-user secret..."
  sleep 2
done

TOKEN="$(kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath='{.data.token}' | base64 -d)"
printf "%s" "$TOKEN" > "$TOKEN_PATH"

echo -e "\n🔌 Starting port-forward to Kubernetes Dashboard at https://localhost:8443 ...\n"
nohup kubectl -n kubernetes-dashboard \
  port-forward svc/kubernetes-dashboard-kong-proxy 8443:443 >/dev/null 2>&1 &

echo -e "\n✅ Cluster setup complete."
echo "📄 Token saved to $TOKEN_PATH"
echo "🌐 Dashboard: https://localhost:8443"
echo -e "\n📝 To access the dashboard, use the token from $TOKEN_PATH.\n"
