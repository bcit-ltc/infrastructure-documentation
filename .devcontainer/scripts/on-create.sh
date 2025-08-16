#!/usr/bin/env bash
set -euo pipefail

log() { printf '[on-create] %s\n' "$*" | tee -a "$HOME/status"; }

log "=== on-create start ==="

# Add local k3d registry to /etc/hosts (system scope)
echo "Adding local k3d registry to /etc/hosts..."
echo "127.0.0.1     registry.localhost" | sudo tee -a /etc/hosts > /dev/null

# Only run updates during prebuilds (CODESPACE_NAME == "null")
if [[ "${CODESPACE_NAME:-}" == "null" ]]; then
  log "prebuild: apt update/upgrade"
  sudo apt update
  sudo apt -y upgrade
  sudo apt autoremove -y
fi

log "=== on-create complete ==="
