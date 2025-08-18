#!/usr/bin/env zsh
emulate -L zsh
set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="${0:A:h}"
ZDOTDIR="$SCRIPT_DIR" . "$SCRIPT_DIR/.zshenv" 2>/dev/null || true
. "$SCRIPT_DIR/env.sh"
. "$SCRIPT_DIR/lib.sh"

need k3d
need kubectl

: "${K3D_CFG_PATH:?K3D_CFG_PATH must point to a k3d config YAML}"
[ -r "$K3D_CFG_PATH" ] || die "Config not readable: $K3D_CFG_PATH"

log "Creating k3d cluster from: $K3D_CFG_PATH"

# If you export K3D_CLUSTER_NAME in env.sh, this makes reruns safe.
if [[ -n "${K3D_CLUSTER_NAME:-}" ]] && k3d cluster list --no-headers 2>/dev/null | awk '{print $1}' | grep -qx -- "$K3D_CLUSTER_NAME"; then
  log "Cluster '$K3D_CLUSTER_NAME' already exists; skipping create."
else
  k3d cluster create --config "$K3D_CFG_PATH" --wait --timeout 180s
fi

log "Fetching cluster info..."
kubectl cluster-info || true

log "Waiting for nodes to be Ready..."
kubectl wait node --all --for=condition=Ready --timeout=120s || true

log "Cluster nodes:"
kubectl get nodes -o wide

log "✅ Cluster setup complete."
