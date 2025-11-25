#!/usr/bin/env sh
set -euo pipefail

# ----------------------------------------
# Config via environment / args
# ----------------------------------------

# Prefer positional argument as STATIC_ROOT, else IMAGE_STATIC_ROOT, else /usr/share/nginx/html
if [ "${1-}" != "" ]; then
  STATIC_ROOT="$1"
else
  STATIC_ROOT="${IMAGE_STATIC_ROOT:-${STATIC_ROOT:-/usr/share/nginx/html}}"
fi

# Namespace (e.g., GitHub org slug)
CDN_NAMESPACE="${CDN_NAMESPACE:-bcit-ltc}"

# Canonical app name / slug
APP_NAME="${APP_NAME:-unknown-app}"

# Version file (matches your CI + Dockerfile: conf.d/cdn/CDN_ASSET_VERSION)
VERSION_FILE="${CDN_VERSION_FILE:-./conf.d/cdn/CDN_ASSET_VERSION}"

# Optional: skip rewriting in local dev (e.g., SKIP_CDN=1 / true / yes)
SKIP_CDN="${SKIP_CDN:-0}"

# Local URL prefix for static assets in the app
# Default matches your STATIC_SUBDIR=assets → /assets/
CDN_LOCAL_PREFIX="${CDN_LOCAL_PREFIX:-/assets/}"

# File extensions to rewrite (comma-separated)
CDN_FILE_EXTS="${CDN_FILE_EXTS:-html,css,js,map,txt,xml,webmanifest}"

# Base URL of the CDN origin (scheme + host + optional fixed path like /cdn)
# e.g. https://your-frontdoor.example.net/cdn
CDN_BASE_URL="${CDN_BASE_URL:-}"

# ----------------------------------------
# Early exit for local dev
# ----------------------------------------

case "$(printf '%s' "$SKIP_CDN" | tr 'A-Z' 'a-z')" in
  1|true|yes|on)
    echo "[cdn_rewrite] SKIP_CDN is set ($SKIP_CDN). Skipping CDN rewrite."
    exit 0
    ;;
esac

# ----------------------------------------
# Validate base URL & version
# ----------------------------------------

if [ -z "$CDN_BASE_URL" ]; then
  echo "[cdn_rewrite] WARNING: CDN_BASE_URL not set, using placeholder origin" >&2
  CDN_BASE_URL="https://bcit-ltc-cdn.example.invalid"
fi

if [ ! -f "$VERSION_FILE" ]; then
  echo "[cdn_rewrite] ERROR: CDN_ASSET_VERSION file not found at $VERSION_FILE" >&2
  exit 1
fi

CDN_ASSET_VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"

if [ -z "$CDN_ASSET_VERSION" ]; then
  echo "[cdn_rewrite] ERROR: CDN_ASSET_VERSION is empty in $VERSION_FILE" >&2
  exit 1
fi

# Normalize local prefix: ensure it starts and ends with a slash
case "$CDN_LOCAL_PREFIX" in
  /*) : ;;   # starts with /
  *)  CDN_LOCAL_PREFIX="/$CDN_LOCAL_PREFIX" ;;
esac

case "$CDN_LOCAL_PREFIX" in
  */) : ;;  # ends with /
  *)  CDN_LOCAL_PREFIX="${CDN_LOCAL_PREFIX}/" ;;
esac

# ----------------------------------------
# Compute CDN prefix
# Layout (matches upload-cdn-assets job):
#   Blob path: <CDN_NAMESPACE>/<APP_NAME>/<CDN_ASSET_VERSION>/assets/...
#   URL:      <CDN_BASE_URL>/<CDN_NAMESPACE>/<APP_NAME>/<CDN_ASSET_VERSION>/assets/...
# ----------------------------------------

CDN_PREFIX="${CDN_BASE_URL%/}/${CDN_NAMESPACE}/${APP_NAME}/${CDN_ASSET_VERSION}"

echo "[cdn_rewrite] Static root: $STATIC_ROOT"
echo "[cdn_rewrite] CDN namespace: $CDN_NAMESPACE"
echo "[cdn_rewrite] App name: $APP_NAME"
echo "[cdn_rewrite] Asset version: $CDN_ASSET_VERSION"
echo "[cdn_rewrite] Local asset prefix: $CDN_LOCAL_PREFIX"
echo "[cdn_rewrite] CDN prefix: $CDN_PREFIX"

# ----------------------------------------
# Build find predicates from CDN_FILE_EXTS
# ----------------------------------------

FIND_EXPR=""
OLD_IFS="$IFS"
IFS=','

for ext in $CDN_FILE_EXTS; do
  ext_trimmed="$(printf '%s' "$ext" | tr -d '[:space:]')"
  [ -z "$ext_trimmed" ] && continue

  if [ -z "$FIND_EXPR" ]; then
    FIND_EXPR="-name '*.${ext_trimmed}'"
  else
    FIND_EXPR="${FIND_EXPR} -o -name '*.${ext_trimmed}'"
  fi
done

IFS="$OLD_IFS"

if [ -z "$FIND_EXPR" ]; then
  echo "[cdn_rewrite] ERROR: No file extensions configured in CDN_FILE_EXTS" >&2
  exit 1
fi

echo "[cdn_rewrite] Rewriting files matching extensions: $CDN_FILE_EXTS"

# ----------------------------------------
# Rewrite URLs
# ----------------------------------------
# Patterns handled:
#   "/assets/..."      → "<CDN_PREFIX>/assets/..."
#   '/assets/...'      → '<CDN_PREFIX>/assets/...'
#   (/assets/...       → (<CDN_PREFIX>/assets/...
#
# Only absolute URLs starting with the configured CDN_LOCAL_PREFIX
# are affected (e.g., "/assets/", "/static/").
# ----------------------------------------

# shellcheck disable=SC2086
find "$STATIC_ROOT" \( $FIND_EXPR \) -print0 \
  | while IFS= read -r -d '' file; do
      echo "[cdn_rewrite] Rewriting in: $file"

      sed -i \
        -e "s#\"${CDN_LOCAL_PREFIX}#\"${CDN_PREFIX}${CDN_LOCAL_PREFIX}#g" \
        -e "s#'${CDN_LOCAL_PREFIX}#'${CDN_PREFIX}${CDN_LOCAL_PREFIX}#g" \
        -e "s#(${CDN_LOCAL_PREFIX}#(${CDN_PREFIX}${CDN_LOCAL_PREFIX}#g" \
        "$file"
    done

echo "[cdn_rewrite] Done."
