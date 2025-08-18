# Use zsh for all recipes and auto-load env via ZDOTDIR
SHELL := /usr/bin/env zsh
export ZDOTDIR := $(CURDIR)/.devcontainer/scripts

# Optional: allow sudo outside the devcontainer (default empty inside)
SUDO ?=

# Tool discovery
K3D      := $(shell command -v k3d)
KUBECTL  := $(shell command -v kubectl)
HELM     := $(shell command -v helm)
SKAFFOLD := $(shell command -v skaffold)
DOCKER   := $(shell command -v docker)

# Files/paths
ENVSH   := $(CURDIR)/.devcontainer/scripts/env.sh
LIBSH   := $(CURDIR)/.devcontainer/scripts/lib.sh
K3D_CFG := $(CURDIR)/.devcontainer/k3d/k3d.yaml

# Targets
.PHONY: help cluster dashboard chart delete

help:
	@echo "Targets:"
	@echo "  cluster         → create k3d cluster using $(K3D_CFG)"
	@echo "  dashboard       → install Kubernetes Dashboard and print login token"
	@echo "  chart           → pull/unpack app chart (set APP_CHART_URL to override default 'oci/{appName}')"
	@echo "  delete          → delete all k3d clusters (local dev cleanup)"

cluster:
	@. "$(ENVSH)"; . "$(LIBSH)"; \
	"$(CURDIR)/.devcontainer/scripts/cluster.sh"
	@. "$(ENVSH)"; . "$(LIBSH)"; \
	"$(CURDIR)/.devcontainer/scripts/app-chart.sh"

dashboard:
	@. "$(ENVSH)"; . "$(LIBSH)"; \
	"$(CURDIR)/.devcontainer/scripts/kubernetes-dashboard.sh"

chart:
	@. "$(ENVSH)"; . "$(LIBSH)"; \
	"$(CURDIR)/.devcontainer/scripts/app-chart.sh"

token:
	@. "$(ENVSH)" && \
	if [ -s "$$TOKEN_PATH" ]; then \
	  echo "Token file: $$TOKEN_PATH"; \
	  echo "---- TOKEN ----"; \
	  cat "$$TOKEN_PATH"; echo; \
	else \
	  echo "No token found. Run 'make dashboard' first."; \
	  exit 1; \
	fi

delete:
	@echo "❌ Deleting all k3d clusters..."
	@. "$(ENVSH)"; \
	if [ -z "$(K3D)" ]; then echo "k3d not found"; exit 127; fi; \
	$(SUDO) $(K3D) cluster delete -a || true; \
	rm -f "$$TOKEN_PATH"
