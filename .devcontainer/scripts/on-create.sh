#!/usr/bin/env bash
set -euo pipefail

log() { printf '[on-create] %s\n' "$*" | tee -a "$HOME/status"; }

log "start"

# Add local k3d registry to /etc/hosts (system scope)
echo "127.0.0.1     registry.localhost" | sudo tee -a /etc/hosts > /dev/null

# Only run APT during prebuilds (CODESPACE_NAME == "null")
if [[ "${CODESPACE_NAME:-}" == "null" ]]; then
  log "prebuild: apt update/upgrade"
  sudo apt update
  sudo apt -y upgrade
  sudo apt autoremove -y
fi

log "complete"
