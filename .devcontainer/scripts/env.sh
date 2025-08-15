# .devcontainer/scripts/env.sh
# Central defaults; export only.

# Determine a stable workspace root:
# - Prefer explicit WORKSPACE_ROOT if set
# - Otherwise derive from this file's location: <repo>/.devcontainer/scripts/env.sh -> <repo>
# - Otherwise fall back to Codespaces var or PWD
if [ -z "${WORKSPACE_ROOT:-}" ]; then
  if [ -n "${BASH_SOURCE[0]:-}" ]; then
    _ENV_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
    WORKSPACE_ROOT="$(cd -- "${_ENV_DIR}/../.." && pwd -P)"
  else
    WORKSPACE_ROOT="${CODESPACE_VSCODE_FOLDER:-$PWD}"
  fi
fi

# App identity and XDG-style state paths
: "${APP_ID:=$(basename "$WORKSPACE_ROOT")}"
: "${APP_STATE_DIR:=$HOME/.local/state/$APP_ID}"
: "${TOKEN_PATH:=$APP_STATE_DIR/dashboard-token.txt}"
: "${PRINTED_FLAG:=$APP_STATE_DIR/.printed_dashboard_token}"

# k3d config path anchored to the same root
: "${K3D_CFG_PATH:=$WORKSPACE_ROOT/.devcontainer/k3d/k3d.yaml}"

export WORKSPACE_ROOT APP_ID APP_STATE_DIR TOKEN_PATH PRINTED_FLAG K3D_CFG_PATH
