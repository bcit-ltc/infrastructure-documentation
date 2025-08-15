# Use bash with strict flags for all recipes
SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
.SILENT:

.PHONY: help env-check bootstrap cluster print-dashboard-token

DEFAULT_GOAL := help

help:
	echo "Targets:"
	echo "  make bootstrap              # Run full setup script (same flow as postCreate)"
	echo "  make cluster                # Create k3d, save token, port-forward (delegates to scripts/cluster.sh)"
	echo "  make print-dashboard-token  # Print the saved dashboard token with a banner"
	echo "  make env-check              # Verify env is loaded via direnv"

# Ensure direnv-loaded env is present (lightweight guard)
env-check:
	if [[ -z "${K3D_CFG_PATH:-}" ]]; then
	  echo "Environment not loaded. Run 'direnv allow .' (or ensure the VS Code Direnv extension is active)."; \
	  exit 1; \
	fi

# For manual runs; mirrors what postCreateCommand triggers
bootstrap: env-check
	.devcontainer/scripts/post-create.sh

# Thin wrapper to your real work (no direnv install, no shell mutations here)
cluster: env-check
	.devcontainer/scripts/cluster.sh

# Consistent banner with the .bashrc snippet
print-dashboard-token:
	if [[ -s "$$HOME/dashboard-token.txt" ]]; then
	  echo ""; \
	  echo "======================== DASHBOARD ADMIN TOKEN ========================"; \
	  cat "$$HOME/dashboard-token.txt"; \
	  echo "========================================================================"; \
	  echo "📄 Saved to: $$HOME/dashboard-token.txt"; \
	  echo ""; \
	else
	  echo "No token found at $$HOME/dashboard-token.txt"; \
	fi
