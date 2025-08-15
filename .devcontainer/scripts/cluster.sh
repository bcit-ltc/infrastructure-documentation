#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Creating k3d cluster..."
k3d cluster create --config .devcontainer/k3d/k3d.yaml

echo "📡 Fetching cluster info..."
kubectl cluster-info | tee -a "$HOME/status"

echo "⏳ Waiting for Kubernetes Dashboard to become ready..."
kubectl wait --for=condition=available --timeout=120s deployment/kubernetes-dashboard -n kubernetes-dashboard || true
until kubectl get secret admin-user -n kubernetes-dashboard >/dev/null 2>&1; do
  echo "   ...still waiting for admin-user secret..."
  sleep 2
done

TOKEN="$(kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath='{.data.token}' | base64 -d)"
printf "%s" "$TOKEN" > "$HOME/dashboard-token.txt"

echo "🔌 Starting port-forward to Kubernetes Dashboard at https://localhost:8443 ..."
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443 >/dev/null 2>&1 &

echo "✅ Cluster setup complete."
echo "📄 Token saved to $HOME/dashboard-token.txt"
echo "🌐 Dashboard: https://localhost:8443"
