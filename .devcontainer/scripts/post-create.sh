#!/usr/bin/env bash
set -euo pipefail

# Load shared env next to this script, even if called via a relative path or symlink
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
. "$SCRIPT_DIR/env.sh"

log() { printf '[post-create] %s\n' "$*" | tee -a "$HOME/status"; }
log "start"

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

# Small quality-of-life alias (idempotent)
grep -q "^alias l=" "$TARGET_RC" 2>/dev/null || echo "alias l='ls -hAlF'" >> "$TARGET_RC"

# # Print-once token banner (idempotent, uses XDG state paths)
# SNIP_GUARD="# --- print-dashboard-token (managed) ---"
# if ! grep -qF "$SNIP_GUARD" "$TARGET_RC" 2>/dev/null; then
#   cat >> "$TARGET_RC" <<EOF
# $SNIP_GUARD
# if [ -f "$TOKEN_PATH" ] && [ ! -f "$PRINTED_FLAG" ]; then
#   echo ""
#   echo "======================== DASHBOARD ADMIN TOKEN ========================"
#   cat "$TOKEN_PATH"
#   echo "========================================================================"
#   echo "📄 Saved to: $TOKEN_PATH"
#   echo ""
#   touch "$PRINTED_FLAG"
# fi
# # --- end ---
# EOF
# fi

# User-level bash completion for k3d (no writes to /etc)
k3d completion bash > "$HOME/.local/share/bash-completion/completions/k3d" 2>/dev/null || true

# # -----------------------------------------------------------------------------
# # Skaffold wrapper (user-scoped; recursion-safe; respects -f/--filename)
# # -----------------------------------------------------------------------------
# WRAP_DIR="$HOME/.local/bin"
# cat > "$WRAP_DIR/skaffold" <<'EOF'
# #!/usr/bin/env bash
# set -euo pipefail

# # --- find the real skaffold (avoid recursion) ---
# SELF_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# SELF_PATH="$SELF_DIR/$(basename "$0")"
# REAL=""
# # bash builtin: prints only pathnames, one per line
# mapfile -t _cands < <(type -ap skaffold 2>/dev/null || true)
# for cand in "${_cands[@]}"; do
#   [[ "$cand" == "$SELF_PATH" ]] && continue
#   [[ "$cand" == *"/.local/bin/"* ]] && continue      # where this wrapper usually lives
#   [[ "$cand" == *"/.devcontainer/.direnv/bin/"* ]] && continue
#   REAL="$cand"; break
# done
# if [[ -z "${REAL:-}" ]]; then
#   echo "Error: could not locate real 'skaffold' binary on PATH." >&2
#   exit 127
# fi

# # Respect explicit -f/--filename if the user provides it
# for arg in "$@"; do
#   case "$arg" in
#     -f|--filename|-f=*|--filename=*) exec "$REAL" "$@";;
#   esac
# done

# # Default to workspace config via env var; ignored by subcommands that don't support it
# ROOT="${WORKSPACE_ROOT:-$PWD}"
# CFG_REL=".devcontainer/skaffold/skaffold.yaml"
# export SKAFFOLD_FILENAME="${SKAFFOLD_FILENAME:-${ROOT%/}/${CFG_REL}}"

# # Friendly cluster nudge for cmds that need a cluster
# sub=""
# for tok in "$@"; do [[ "$tok" == -* ]] || { sub="$tok"; break; }; done
# case "${sub:-}" in
#   dev|run|deploy|delete|apply)
#     if ! kubectl version --request-timeout=3s --short >/dev/null 2>&1; then
#       echo "❌ No reachable Kubernetes cluster/context."
#       echo "   Tip: run 'make cluster' then retry: skaffold $*"
#       exit 1
#     fi
#     ;;
# esac

# exec "$REAL" "$@"
# EOF
# chmod +x "$WRAP_DIR/skaffold"

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

log "complete"
