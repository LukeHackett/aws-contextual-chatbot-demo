# Toolings
PYTHON = python3
PIP = ${PYTHON} -m pip
VIRTUALENV = ${PYTHON} -m virtualenv

# Directories
WORK_DIR = $(shell pwd)
VENV_DIR = $(WORK_DIR)/venv

# AWS Variables
AWS_REGION = us-east-1
AWS_PROFILE = personal

# from https://suva.sh/posts/well-documented-makefiles/
default: help
.PHONY: help
help:  ## Displays this help message
	awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: clean
clean: ## Cleans the project directory and removes venv directory
	echo $(WORK_DIR)
	rm -rf $(VENV_DIR)

.PHONY: setup
setup: ## Performs the initial setup of the project directory
	echo "Installing virtualenv..."
	$(PIP) install --user virtualenv
	echo "Creating new virtualenv..."
	$(VIRTUALENV) --prompt "agent" $(VENV_DIR)
	echo "New virtualenv created. Remember to activate before using the virutalenv."

.PHONY: install
install: requirements.txt ## Installs the dependencies for this project
	test -d $(VENV_DIR) || $(VIRTUALENV)
	. $(VENV_DIR)/bin/activate; $(PIP) install -Ur requirements.txt
