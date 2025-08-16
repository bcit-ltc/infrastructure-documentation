#!/usr/bin/env bash
set -euo pipefail

# Load shared env next to this script, even if called via a relative path or symlink
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
. "$SCRIPT_DIR/env.sh"

# Deploy kubernetes dashboard
if helm repo list | grep -q '^kubernetes-dashboard'; then
  echo "Helm repo 'kubernetes-dashboard' already exists, skipping add."
else
  helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard
fi
helm repo update

helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --namespace kubernetes-dashboard --create-namespace

# Create admin user and service account
cat <<'EOF' | kubectl create -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: admin-user
    namespace: kubernetes-dashboard
---
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "admin-user"
type: kubernetes.io/service-account-token
EOF

# Poll until the admin-user secret exists
MAX_ATTEMPTS=10
ATTEMPT=1
until kubectl get secret admin-user -n kubernetes-dashboard >/dev/null 2>&1; do
  if (( ATTEMPT > MAX_ATTEMPTS )); then
    echo "❌ Timed out waiting for admin-user secret."
    exit 1
  fi
  echo "   ...still waiting for admin-user secret (attempt $ATTEMPT/$MAX_ATTEMPTS)..."
  sleep 2
  ((ATTEMPT++))
done

TOKEN="$(kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath='{.data.token}' | base64 -d)"
if printf "%s" "$TOKEN" > "$TOKEN_PATH"; then
  echo "📄 Token saved."
else
  echo "⚠️ Failed to save token to $TOKEN_PATH."
fi

echo "🌐 Dashboard: https://localhost:8443"
echo -e "📝 To access the dashboard, use the token from $TOKEN_PATH.\n"
