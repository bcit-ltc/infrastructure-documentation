#!/usr/bin/env bash
set -euo pipefail

# this runs at Codespace creation - not part of pre-build

echo "=== post-create start ===" | tee -a "$HOME/status"

# update repo
# git -C /workspaces/imdb-app pull

# Your bootstrap (cluster, token, port-forward) is owned by your scripts/Makefile
make cluster

# 2) Inject the print-once token banner into the login shell RC
TARGET_RC="$HOME/.bashrc"
if [ "${SHELL:-}" ] && echo "$SHELL" | grep -q zsh; then TARGET_RC="$HOME/.zshrc"; fi

SNIPPET_ID="K8S_DASHBOARD_TOKEN_SNIPPET_V1"
if ! grep -q "$SNIPPET_ID" "$TARGET_RC" 2>/dev/null; then
  touch "$TARGET_RC"
  cat >>"$TARGET_RC" <<'EOF'
# --- Kubernetes Dashboard token banner (print once) --- [K8S_DASHBOARD_TOKEN_SNIPPET_V1]
if [ -f "$HOME/dashboard-token.txt" ] && [ ! -f "$HOME/.printed_dashboard_token" ]; then
  echo ""
  echo "======================== DASHBOARD ADMIN TOKEN ========================"
  cat "$HOME/dashboard-token.txt"
  echo "========================================================================"
  echo "📄 Saved to: $HOME/dashboard-token.txt"
  echo ""
  touch "$HOME/.printed_dashboard_token"
fi
# --- end ---
EOF
fi

echo "=== post-create complete ===" | tee -a "$HOME/status"
