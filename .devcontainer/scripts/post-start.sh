#!/usr/bin/env zsh
set -e
set -o nounset
set -o pipefail

ZDOTDIR="${ZDOTDIR:-$(cd -- "$(dirname "${0:A}")" && pwd -P)}"
. "$ZDOTDIR/env.sh"
. "$ZDOTDIR/lib.sh"

log "post-start start"

# Fix docker.sock permissions (DinD can set root:root)
if [ -S /var/run/docker.sock ]; then
  grp="$(stat -c '%G' /var/run/docker.sock)"
  if [ "$grp" != "docker" ]; then
    log "Fixing docker.sock group → docker"
    command -v sudo >/dev/null 2>&1 && SUDO=sudo || SUDO=
    $SUDO chgrp docker /var/run/docker.sock || true
    $SUDO chmod g+rw /var/run/docker.sock || true
  fi
fi

log "post-start complete"
