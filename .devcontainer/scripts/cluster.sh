#!/usr/bin/env bash
set -euo pipefail

# Load shared env next to this script, even if called via a relative path or symlink
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
. "$SCRIPT_DIR/env.sh"

echo "🚀 Creating k3d cluster..."
k3d cluster create --config "$K3D_CFG_PATH/k3d.yaml"

echo "📡 Fetching cluster info..."
kubectl cluster-info | tee -a "$HOME/status"

echo -e "\n✅ Cluster setup complete.\n"
