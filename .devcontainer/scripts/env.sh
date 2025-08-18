# Shared environment for all scripts and Make recipes (shell-agnostic)

# --- IDs & names ---
export APP_ID="${APP_ID:-infrastructure-documentation}"
export CLUSTER_NAME="${CLUSTER_NAME:-review}"

# --- workspace & state ---
export WORKSPACE_ROOT="${WORKSPACE_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
export APP_STATE_DIR="${APP_STATE_DIR:-$HOME/.local/state/$APP_ID}"
export TOKEN_PATH="${TOKEN_PATH:-$APP_STATE_DIR/k8s-dashboard-token}"
export K3D_CFG_PATH="${K3D_CFG_PATH:-$WORKSPACE_ROOT/.devcontainer/k3d/k3d.yaml}"

# --- registry / images ---
export REGISTRY_HOST="${REGISTRY_HOST:-registry.localhost:5000}"
# export IMAGE_REPO_NO_DOMAIN_app="${IMAGE_REPO_NO_DOMAIN_app:-app}"
# export IMAGE_TAG_app="${IMAGE_TAG_app:-dev}"
# export IMAGE_REGISTRY_app="${IMAGE_REGISTRY_app:-$REGISTRY_HOST}"
# export IMAGE_REPO_app="${IMAGE_REPO_app:-$IMAGE_REPO_NO_DOMAIN_app}"

# Normalize: if IMAGE_REPO_app was set with a registry prefix, strip it.
# case "$IMAGE_REPO_app" in
#   "$REGISTRY_HOST"/*) IMAGE_REPO_app="${IMAGE_REPO_app#${REGISTRY_HOST}/}";;
# esac
# export IMAGE_REPO_app

# --- skaffold defaults ---
export SKAFFOLD_DEFAULT_REPO="${SKAFFOLD_DEFAULT_REPO:-$REGISTRY_HOST}"
export SKAFFOLD_PORT_FORWARD="${SKAFFOLD_PORT_FORWARD:-true}"
export SKAFFOLD_FILENAME="${SKAFFOLD_FILENAME:-.devcontainer/skaffold/skaffold.yaml}"
export SKAFFOLD_ENV_FILE="${SKAFFOLD_ENV_FILE:-$WORKSPACE_ROOT/.devcontainer/skaffold/skaffold.env}"

# --- dockerfile (optional, used by custom image targets) ---
export APP_DOCKERFILE="${APP_DOCKERFILE:-$WORKSPACE_ROOT/Dockerfile}"

# --- PATH for non-interactive shells (Make/CI) ---
for _p in "$HOME/.nix-profile/bin" "/nix/var/nix/profiles/default/bin"; do
  case ":$PATH:" in
    *":${_p}:"*) : ;;
    *) PATH="${_p}:${PATH}" ;;
  esac
done
export PATH
