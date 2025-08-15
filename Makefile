# Use bash with strict flags for all recipes
SHELL := $(shell command -v bash 2>/dev/null)
ifeq ($(SHELL),)
  SHELL := /bin/sh
  .SHELLFLAGS := -eu -c
else
  .SHELLFLAGS := -eu -o pipefail -c
endif
.ONESHELL:
.SILENT:

# ---------------- Project paths (XDG-ish) ----------------
APP_STATE_DIR := $(shell bash -c '. .devcontainer/scripts/env.sh; printf "%s" "$$APP_STATE_DIR"')
TOKEN_PATH    := $(shell bash -c '. .devcontainer/scripts/env.sh; printf "%s" "$$TOKEN_PATH"')
PRINTED_FLAG  := $(shell bash -c '. .devcontainer/scripts/env.sh; printf "%s" "$$PRINTED_FLAG"')
K3D_CFG_PATH  := $(shell bash -c '. .devcontainer/scripts/env.sh; printf "%s" "$$K3D_CFG_PATH"')
# ---------------------------------------------------------

.PHONY: help cluster token _env-check

.DEFAULT_GOAL := help

help:
	@echo "Targets:"
	@echo "  make cluster   # Create k3d, save dashboard token, port-forward"
	@echo "  make token     # Print saved Kubernetes Dashboard token"
	@echo ""

# Internal: verify env and required files (not shown in help)
_env-check:
	mkdir -p "$(APP_STATE_DIR)"
	[ -f "$(K3D_CFG_PATH)" ] || { echo "Missing $(K3D_CFG_PATH)"; exit 1; }

cluster: _env-check
	[ -x .devcontainer/scripts/cluster.sh ] || { echo "cluster.sh not found or not executable"; exit 1; }
	.devcontainer/scripts/cluster.sh
	$(MAKE) token

token:
	if [ -s "$(TOKEN_PATH)" ]; then \
	  echo ""; \
	  echo "======================== DASHBOARD ADMIN TOKEN ========================"; \
	  cat "$(TOKEN_PATH)"; \
	  echo "========================================================================"; \
	  echo "📄 Saved to: $(TOKEN_PATH)"; \
	  echo ""; \
	else \
	  echo "No token found at $(TOKEN_PATH)"; \
	fi
