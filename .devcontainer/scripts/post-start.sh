#!/usr/bin/env bash
set -euo pipefail

log() { printf '[post-start] %s\n' "$*" | tee -a "$HOME/status"; }

log "=== post-start start ==="

# Do NOT auto-trust direnv; users should run `direnv allow` manually
# direnv allow . >/dev/null 2>&1 || true

log "=== post-start complete ==="
