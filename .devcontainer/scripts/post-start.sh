#!/usr/bin/env bash
set -euo pipefail

log() { printf '[post-start] %s\n' "$*" | tee -a "$HOME/status"; }

log "=== post-start start ==="

# Trust .envrc (no-op if already allowed); avoid noisy output
direnv allow . >/dev/null 2>&1 || true

log "=== post-start complete ==="
