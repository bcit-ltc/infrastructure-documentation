#!/usr/bin/env bash
set -euo pipefail

# Load shared env next to this script, even if called via a relative path or symlink
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
. "$SCRIPT_DIR/env.sh"

log() { printf '[post-create] %s\n' "$*" | tee -a "$HOME/status"; }
log "=== post-create start ==="

# Prepare user-scoped dirs
mkdir -p "$APP_STATE_DIR" \
         "$HOME/.local/bin" \
         "$HOME/.local/share/bash-completion/completions" \
         "/workspaces/.codespaces/shared"

# ---- shell RC selection ----
TARGET_RC="$HOME/.bashrc"
if [[ "${SHELL:-}" == *zsh ]]; then TARGET_RC="$HOME/.zshrc"; fi

# Ensure direnv hook (idempotent)
if ! grep -q 'direnv hook' "$TARGET_RC" 2>/dev/null; then
  echo 'eval "$(direnv hook bash)"' >> "$TARGET_RC"
fi

# Always overwrite the default 'alias l=' in .bashrc or .zshrc
sed -i '/^alias l=/d' "$TARGET_RC"
echo "alias l='ls -hAlF'" >> "$TARGET_RC"

# User-level bash completion for k3d (no writes to /etc)
echo "Generating bash completion for k3d..."
k3d completion bash > "$HOME/.local/share/bash-completion/completions/k3d" 2>/dev/null || true

# Replace Codespaces banner (platform reads this path)
NOTICE_WS="/workspaces/.codespaces/shared/first-run-notice.txt"
cat > "$NOTICE_WS" <<'EOF'
👋 Welcome!

🛠  Commands:

 • make help              # project tasks
 • docker compose up      # local dev
 • make cluster           # bring up k3d (confirm k8s deployment)
 • skaffold dev           # deploy to the cluster (after `make cluster`)

EOF

log "=== post-create complete ==="
