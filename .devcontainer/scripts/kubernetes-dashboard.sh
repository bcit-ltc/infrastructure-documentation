#!/usr/bin/env zsh
# Install and configure Kubernetes Dashboard with Helm
emulate -L zsh
set -o errexit
set -o nounset
set -o pipefail

# Resolve script dir and shared env/lib; load env
SCRIPT_DIR="${0:A:h}"
ZDOTDIR="$SCRIPT_DIR" . "$SCRIPT_DIR/.zshenv" 2>/dev/null || true
. "$SCRIPT_DIR/env.sh"
. "$SCRIPT_DIR/lib.sh"

# Common variables
DASHBOARD_NAME="kubernetes-dashboard"
NAMESPACE="${NAMESPACE:-$DASHBOARD_NAME}"
RELEASE="k8s-dashboard"
SA_NAME="admin-user"

# Check dependencies
need kubectl
need helm

# Validate TOKEN_PATH
: "${TOKEN_PATH:?TOKEN_PATH must point to where the dashboard token will be written}"
umask 077   # protect the token file

log "Adding/Updating $DASHBOARD_NAME Helm repo…"
helm repo add $DASHBOARD_NAME https://kubernetes.github.io/dashboard --force-update >/dev/null
helm repo update >/dev/null

log "Installing/Upgrading dashboard…"
# Optional: pin the chart version by exporting DASHBOARD_VERSION="v7.5.0" (example)
helm upgrade --install "$RELEASE" $NAMESPACE/$DASHBOARD_NAME \
  --namespace "$NAMESPACE" --create-namespace \
  --set serviceAccount.create=true \
  --set serviceAccount.name="$SA_NAME" \
  --set service.type=ClusterIP \
  ${DASHBOARD_VERSION:+--version "$DASHBOARD_VERSION"} \
  --wait --timeout=5m

log "Ensuring ServiceAccount + clusterrolebinding for ${SA_NAME}…"
# Create SA explicitly if the chart did not create it under this name
if ! kubectl -n "$NAMESPACE" get sa "$SA_NAME" >/dev/null 2>&1; then
  kubectl -n "$NAMESPACE" create sa "$SA_NAME"
fi

# Create (idempotent) cluster-admin binding for the SA
if ! kubectl get clusterrolebinding "$SA_NAME" >/dev/null 2>&1; then
  kubectl create clusterrolebinding "$SA_NAME" \
    --clusterrole=cluster-admin \
    --serviceaccount="$NAMESPACE:$SA_NAME"
fi

mkdir -p -- "$(dirname -- "$TOKEN_PATH")"

# Prefer projected token on K8s 1.24+ (requires RBAC: create on serviceaccounts/token)
if kubectl -n "$NAMESPACE" create token "$SA_NAME" --duration=24h > "$TOKEN_PATH" 2>/dev/null; then
  log "Projected token created at $TOKEN_PATH"
else
  log "Projected token failed (RBAC or API setting). Creating annotated Secret token…"
  cat <<EOF | kubectl -n "$NAMESPACE" apply -f - >/dev/null
apiVersion: v1
kind: Secret
metadata:
  name: ${SA_NAME}-token
  annotations:
    kubernetes.io/service-account.name: ${SA_NAME}
type: kubernetes.io/service-account-token
EOF

  # Wait for the controller to populate the token field
  TOKEN_BASE64=""
  for i in {1..20}; do
    TOKEN_BASE64="$(kubectl -n "$NAMESPACE" get secret "${SA_NAME}-token" -o jsonpath='{.data.token}' 2>/dev/null || true)"
    [[ -n "$TOKEN_BASE64" ]] && break
    sleep 1
  done
  if [[ -z "$TOKEN_BASE64" ]]; then
    echo "[kubernetes-dashboard.sh] ERROR: Failed to obtain a ServiceAccount token" >&2
    exit 1
  fi
  print -r -- "$TOKEN_BASE64" | base64 -d > "$TOKEN_PATH"
  log "Secret-based token saved to $TOKEN_PATH"
fi

# Determine a sensible port-forward target (v7 uses Kong proxy)
svc_target="svc/${RELEASE}-kong-proxy"
if ! kubectl -n "$NAMESPACE" get "$svc_target" >/dev/null 2>&1; then
  # Fallback to legacy service name
  svc_target="svc/${RELEASE}-kubernetes-dashboard"
fi

log "To access the dashboard via port-forward:"
echo "  kubectl -n $NAMESPACE port-forward $svc_target 8443:8443 2>/dev/null || kubectl -n $NAMESPACE port-forward $svc_target 8443:443"
echo "Then open https://127.0.0.1:8443/ and paste the token from:"
echo "  $TOKEN_PATH"
log "✅ Kubernetes Dashboard setup complete."
