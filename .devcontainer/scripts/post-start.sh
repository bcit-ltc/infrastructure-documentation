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



log "=== post-start start ==="

# Fix docker.sock permissions (DinD can set root:root)
if [ -S /var/run/docker.sock ]; then
  grp="$(stat -c '%G' /var/run/docker.sock)"
  if [ "$grp" != "docker" ]; then
    log "Fixing docker.sock group → docker"
    chgrp docker /var/run/docker.sock || true
    chmod g+rw /var/run/docker.sock || true
  fi
fi

log "=== post-start complete ==="
