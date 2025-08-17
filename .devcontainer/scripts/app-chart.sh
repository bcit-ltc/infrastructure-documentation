#!/usr/bin/env bash
set -euo pipefail

# Load shared env next to this script, even if called via a relative path or symlink
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
. "$SCRIPT_DIR/env.sh"

# Retrieve app chart and move into location for skaffold
if [ -d "app-chart" ]; then
  echo "⚠️ Directory app-chart already exists. Skipping chart pull and move."
else
  echo "📡 Retrieving and unpacking app helm chart..."

  # Assuming public access
  helm pull oci://ghcr.io/$ORG_NAME/oci/$APP_ID --untar
  mv "$APP_ID" "app-chart"
fi

echo -e "\n✅ Chart retrieval complete.\n"
