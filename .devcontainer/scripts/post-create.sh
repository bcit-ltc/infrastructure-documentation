#!/usr/bin/env bash
set -e
set -o nounset
set -o pipefail

if [ -n "${BASH_SOURCE:-}" ]; then
  _this="${BASH_SOURCE[0]}"
elif [ -n "${(%):-%N}" ] 2>/dev/null; then
  _this="${(%):-%N}"
else
  _this="$0"
fi
SCRIPT_DIR="$(cd -- "$(dirname -- "$_this")" && pwd -P)"

# Load env + lib
. "$SCRIPT_DIR/env.sh"
. "$SCRIPT_DIR/lib.sh"



log "=== post-create start ==="

# Prepare user-scoped dirs
mkdir -p "$APP_STATE_DIR" "$HOME/.local/bin"

# Ensure the user is in the "docker" group so docker CLI works without sudo.
if ! getent group docker >/dev/null 2>&1; then
  log "Creating 'docker' group"
  groupadd -f docker
fi
if id -nG "$USER" | grep -qvw docker; then
  log "Adding user '$USER' to 'docker' group"
  usermod -aG docker "$USER" || true
  log "You may need to re-open the shell for group changes to take effect."
fi

# Write skaffold.env expected by direnv and Skaffold templating
cat > "$SKAFFOLD_ENV_FILE" <<EOF
SKAFFOLD_DEFAULT_REPO=$SKAFFOLD_DEFAULT_REPO
SKAFFOLD_PORT_FORWARD=$SKAFFOLD_PORT_FORWARD
SKAFFOLD_FILENAME=$SKAFFOLD_FILENAME
EOF
log "Wrote $SKAFFOLD_ENV_FILE"

# ---- Install Dagger CLI (latest) ----
install_dagger() {
  set -euo pipefail
  # Prefer a global install so all shells/users see it; fall back to user-local.
  if command -v sudo >/dev/null 2>&1; then
    curl -fsSL https://dl.dagger.io/dagger/install.sh | BIN_DIR=/usr/local/bin sudo -E sh
  else
    mkdir -p "$HOME/.local/bin"
    curl -fsSL https://dl.dagger.io/dagger/install.sh | BIN_DIR="$HOME/.local/bin" sh
    case ":${PATH}:" in
      *":$HOME/.local/bin:"*) ;; # already on PATH
      *) echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$TARGET_RC" ;;
    esac
  fi
}
install_dagger

# direnv hook to load env vars
if command -v direnv >/dev/null 2>&1; then
  case "${SHELL:-}" in
    *zsh)  grep -q 'direnv hook zsh'  "$HOME/.zshrc"  2>/dev/null || echo 'eval "$(direnv hook zsh)"'  >> "$HOME/.zshrc" ;;
    *bash) grep -q 'direnv hook bash' "$HOME/.bashrc" 2>/dev/null || echo 'eval "$(direnv hook bash)"' >> "$HOME/.bashrc" ;;
  esac
fi



log "=== post-create complete ==="
