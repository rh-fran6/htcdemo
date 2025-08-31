SHELL := /bin/bash

# ---------- Layout ----------
ANSIBLE_DIR       ?= ansible
VAULT_OPTS ?= --ask-vault-pass

# ---------- Config (override at CLI if you like) ----------
# Put everything under the ansible/ subfolder
PYTHON_SYS        ?= python3
VENV              ?= $(ANSIBLE_DIR)/.venv
VENV_CLEAN        := $(strip $(VENV))
VENV_BIN          := $(VENV_CLEAN)/bin
# Absolute paths so they work even after `cd $(ANSIBLE_DIR)`
VENV_BIN_ABS      := $(abspath $(VENV_BIN))

PYTHON            := $(VENV_BIN_ABS)/python
ANSIBLE_PLAYBOOK  := $(VENV_BIN_ABS)/ansible-playbook
ANSIBLE_GALAXY    := $(VENV_BIN_ABS)/ansible-galaxy

# All inputs/outputs now live inside ansible/
VARS              ?= $(ANSIBLE_DIR)/vars.yaml
REQUIREMENTS      ?= $(ANSIBLE_DIR)/requirements.yaml
COLLECTIONS_PATH  ?= $(ANSIBLE_DIR)/collections
ANSIBLE_CFG       ?= $(ANSIBLE_DIR)/ansible.cfg

# Stage 1: the play that CALLS YOUR ROLE to render the Jinja template
RENDER_PLAYBOOK   ?= $(ANSIBLE_DIR)/stage1-generate.yaml

# Stage 2: the path of the rendered playbook produced by Stage 1
RENDERED_PLAYBOOK ?= $(ANSIBLE_DIR)/build/generated-playbook.yaml

# Absolute path for collections so ansible.cfg is unambiguous
ABS_COLLECTIONS_PATH := $(abspath $(COLLECTIONS_PATH))

# ---------- Phonies ----------
.PHONY: all run venv deps render deploy clean clean-venv clean-all show print-vars

# Full pipeline
all: run
run: deps render

# 1) Recreate venv from scratch (self-cleaning)
venv:
	@if [ -d "$(VENV_CLEAN)" ]; then \
	  echo ">>> Removing existing venv at $(VENV_CLEAN)"; rm -rf "$(VENV_CLEAN)"; \
	fi
	@echo ">>> Creating virtualenv at $(VENV_CLEAN)"
	$(PYTHON_SYS) -m venv "$(VENV_CLEAN)"
	@echo ">>> Upgrading pip"
	"$(VENV_BIN_ABS)/python" -m pip install --upgrade pip setuptools wheel

# 2) Install Python deps + Ansible collections and write ansible.cfg
deps:
	@echo ">>> Installing Python dependencies into venv"
	"$(PYTHON)" -m pip install "ansible-core>=2.15" kubernetes
	@echo ">>> Installing Ansible collections into $(COLLECTIONS_PATH)"
	@mkdir -p "$(COLLECTIONS_PATH)"
	"$(ANSIBLE_GALAXY)" collection install -r "$(REQUIREMENTS)" -p "$(COLLECTIONS_PATH)"
	@echo ">>> Writing $(ANSIBLE_CFG)"
	@mkdir -p "$(ANSIBLE_DIR)"
	@printf "[defaults]\ncollections_paths = %s\n" "$(ABS_COLLECTIONS_PATH)" > "$(ANSIBLE_CFG)"

# 3) Stage 1: render the playbook via your role-based play
render:
	@echo ">>> Rendering via $(RENDER_PLAYBOOK) (calls your render role)"
	@mkdir -p "$(ANSIBLE_DIR)/build"
	@cd "$(ANSIBLE_DIR)" && "$(ANSIBLE_PLAYBOOK)" -e @$$(basename "$(VARS)") $$(basename "$(RENDER_PLAYBOOK)")


# 4) Stage 2: run the rendered playbook
# ansible-vault encrypt_string --ask-vault-pass 'ghp_yourRealTokenHere' --name github_tokendeploy:
deploy:
	@echo ">>> Deploying rendered playbook: $(RENDERED_PLAYBOOK)"
	@test -f "$(RENDERED_PLAYBOOK)" || { echo "ERROR: $(RENDERED_PLAYBOOK) not found"; exit 1; }
	"$(ANSIBLE_PLAYBOOK)" $(VAULT_OPTS) -e @"$(VARS)" "$(RENDERED_PLAYBOOK)"

# Utilities
clean-venv:
	@echo ">>> Removing venv (if any)"
	@rm -rf "$(VENV_CLEAN)"

clean:
	@echo ">>> Cleaning build artifacts"
	@rm -rf "$(VENV_CLEAN)" "$(COLLECTIONS_PATH)" "$(ANSIBLE_CFG)" "$(ANSIBLE_DIR)/build"

clean-all: clean

show:
	@echo "ANSIBLE_DIR=$(ANSIBLE_DIR)"
	@echo "PYTHON_SYS=$(PYTHON_SYS)"
	@echo "VENV=$(VENV_CLEAN)"
	@echo "VENV_BIN=$(VENV_BIN)"
	@echo "RENDER_PLAYBOOK=$(RENDER_PLAYBOOK)"
	@echo "RENDERED_PLAYBOOK=$(RENDERED_PLAYBOOK)"
	@echo "COLLECTIONS_PATH=$(COLLECTIONS_PATH)"
	@echo "ANSIBLE_CFG=$(ANSIBLE_CFG)"

print-vars:
	@printf 'VENV=[%s]\n' '$(VENV)' | cat -A
	@printf 'VENV_CLEAN=[%s]\n' '$(VENV_CLEAN)' | cat -A
	@printf 'VENV_BIN=[%s]\n' '$(VENV_BIN)' | cat -A
	@printf 'ANSIBLE_PLAYBOOK=[%s]\n' '$(ANSIBLE_PLAYBOOK)' | cat -A
