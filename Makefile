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

.PHONY: help cluster token cluster.run _env-check dashboard app-chart

.DEFAULT_GOAL := help

help:
	@echo "Targets:"
	@echo "  make cluster   # Create k3d, save dashboard token, port-forward"
	@echo "  make dashboard # Setup Kubernetes Dashboard"
	@echo "  make token     # Print saved Kubernetes Dashboard token"
	@echo ""

cluster: _env-check cluster.run app-chart token   # aggregator target, no recipe

cluster.run:
	[ -x .devcontainer/scripts/cluster.sh ] || { echo "cluster.sh not found or not executable"; exit 1; }
	.devcontainer/scripts/cluster.sh

app-chart:
	[ -x .devcontainer/scripts/app-chart.sh ] || { echo "app-chart.sh not found or not executable"; exit 1; }
	.devcontainer/scripts/app-chart.sh

dashboard:
	[ -x .devcontainer/scripts/kubernetes-dashboard.sh ] || { echo "kubernetes-dashboard.sh not found or not executable"; exit 1; }
	.devcontainer/scripts/kubernetes-dashboard.sh

token:
	if [ -s "$(TOKEN_PATH)" ]; then \
	  echo -e "\n======================== DASHBOARD ADMIN TOKEN ========================"; \
	  cat "$(TOKEN_PATH)"; \
	  echo -e "\n========================================================================"; \
	  echo "📄 Saved to: $(TOKEN_PATH)"; \
	  echo -e "\nNow wait a moment and run 'kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard-kong-proxy 8443:443' to access the dashboard.\n"; \
	else \
	  echo "No token found at $(TOKEN_PATH)"; \
	fi

delete:
	@echo "Deleting all k3d clusters..."
	@if command -v k3d >/dev/null 2>&1; then \
	  k3d cluster delete -a || true; \
	else \
	  echo "k3d not found, skipping cluster deletion"; \
	fi
	@rm -f "$(TOKEN_PATH)"
	@echo "Cleanup complete."
