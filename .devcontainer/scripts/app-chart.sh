#!/usr/bin/env zsh
# Retrieve app helm chart and store locally in "./app-chart"
emulate -L zsh
set -o errexit
set -o nounset
set -o pipefail
setopt NO_NOMATCH
setopt EXTENDED_GLOB

# Resolve script dir and shared env/lib; load env
SCRIPT_DIR="${0:A:h}"
ZDOTDIR="$SCRIPT_DIR" . "$SCRIPT_DIR/.zshenv" 2>/dev/null || true
. "$SCRIPT_DIR/env.sh"
. "$SCRIPT_DIR/lib.sh"

# Check dependencies
need helm

log "Retrieving app chart into ./app-chart"

# Determine chart reference and optional version
chart_ref=""
version="${APP_CHART_VERSION:-}"

# If APP_CHART_URL is provided, use it directly; otherwise construct from REGISTRY_HOST/ORG_NAME/APP_ID
if [[ -n "${APP_CHART_URL:-}" ]]; then
  chart_ref="${APP_CHART_URL}"
else
  : "${APP_ID:?APP_ID must be set when APP_CHART_URL is not set}"
  : "${ORG_NAME:?ORG_NAME must be set when APP_CHART_URL is not set}"
  chart_ref="oci://${REGISTRY_HOST}/${ORG_NAME}/oci/${APP_ID}"
fi

# Normalize reference (strip any trailing slash) so Helm gets a valid reference
chart_ref="${chart_ref%/}"

# Derive the chart directory name from the normalized ref (last path component)
temp_app_id="${chart_ref##*/}"

# Work in a temp dir under CWD so final moves are atomic on same filesystem
tdir="$(mktemp -d -p . .chart.XXXXXX)"
(
  set -o errexit -o nounset -o pipefail
  trap 'rm -rf -- "$tdir"' EXIT INT TERM

  # Bind the temporary chart name inside the subshell without exporting
  CHART_NAME="$temp_app_id"

  unpack="$tdir/unpack"
  mkdir -p "$unpack"

  if [[ -n "$version" ]]; then
    log "helm pull: $chart_ref (version: $version)"
    helm pull "$chart_ref" --version "$version" --untar --untardir "$unpack"
  else
    log "helm pull: $chart_ref"
    helm pull "$chart_ref" --untar --untardir "$unpack"
  fi

  # The OCI layout places chart files under the chart name directory at the root of the tarball
  src_dir="$unpack/${CHART_NAME}"
  [[ -d "$src_dir" ]] || die "Expected chart directory '$CHART_NAME' not found under $unpack"
  [[ -f "$src_dir/Chart.yaml" ]] || die "Chart.yaml not found in $src_dir"

  stage="$tdir/app-chart.tmp"
  mv -- "$src_dir" "$stage"

  # Optional: resolve dependencies & lint (non-fatal)
  # ( cd "$stage" && helm dependency build >/dev/null 2>&1 || true )
  # ( cd "$stage" && helm lint || true )

  rm -rf -- "app-chart"
  mv -- "$stage" "app-chart"
)

[[ -d "app-chart" ]] || die "Chart directory not found: app-chart"
[[ -f "app-chart/Chart.yaml" ]] || die "Chart.yaml missing in app-chart"

log "✅ Chart ready at ./app-chart"
