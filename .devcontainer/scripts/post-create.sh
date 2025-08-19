#!/usr/bin/env zsh
# Post-create script for setting up the devcontainer environment
set -e
set -o nounset
set -o pipefail

ZDOTDIR="${ZDOTDIR:-$(cd -- "$(dirname "${0:A}")" && pwd -P)}"
. "$ZDOTDIR/env.sh"
. "$ZDOTDIR/lib.sh"

log "post-create start"

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

# direnv hook (zsh)
TARGET_RC="$HOME/.zshrc"
if ! grep -q 'direnv hook zsh' "$TARGET_RC" 2>/dev/null; then
  echo 'eval "$(direnv hook zsh)"' >> "$TARGET_RC"
  log "Added direnv hook to $TARGET_RC"
fi

log "post-create complete"
