#!/usr/bin/env bash
set -euo pipefail

# Load shared env next to this script, even if called via a relative path or symlink
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
. "$SCRIPT_DIR/env.sh"

# Retrieve app chart and move into location for skaffold
helm pull oci://ghcr.io/$ORG_NAME/oci/$APP_ID --untar --destination .devcontainer
mv .devcontainer/$APP_ID .devcontainer/app-chart
