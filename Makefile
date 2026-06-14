# ==============================================================================
#                  __  __ ______ _____  _      _____ _   _ 
#                 |  \/  |  ____|  __ \| |    |_   _| \ | |
#                 | \  / | |__  | |__) | |      | | |  \| |
#                 | |\/| |  __| |  _  /| |      | | | . ` |
#                 | |  | | |____| | \ \| |____ _| |_| |\  |
#                 |_|  |_|______|_|  \_\______|_____|_| \_|
#                                                          
#             T U I   B U I L D   &   D E V E L O P M E N T   S Y S T E M
# ==============================================================================

SHELL := /bin/bash
export CC ?= clang

# Resolve merlin dynamically (Check PATH, fallback to adjacent repo, fallback to global install)
ifeq (, $(shell command -v merlin 2>nul || where merlin 2>nul))
    ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
    ifneq (, $(wildcard $(ROOT_DIR)../merlin))
        MERLIN := $(ROOT_DIR)../merlin/bin/merlin$(if $(OS),.exe,)
    else
        MERLIN := $(HOME)/.merlin/bin/merlin$(if $(OS),.exe,)
    endif
else
    MERLIN := merlin
endif

.PHONY: default
default: all

$(MERLIN):
	@if [ "$(MERLIN)" = "$(ROOT_DIR)../merlin/bin/merlin$(if $(OS),.exe,)" ]; then \
		echo "[BOOTSTRAP] Merlin not found in PATH. Building from adjacent repository (../merlin)..."; \
		$(MAKE) -C $(ROOT_DIR)../merlin; \
	else \
		echo "[BOOTSTRAP] Merlin not found. Installing globally via script..."; \
		curl -sSL https://github.com/yutila-org/merlin/releases/download/alpha/install.sh | bash; \
	fi

.PHONY: all
all: $(MERLIN)
	@$(MERLIN) all $(if $(RELEASE),RELEASE=1,)

.PHONY: test
test: $(MERLIN)
	@$(MERLIN) test $(if $(RELEASE),RELEASE=1,)

.PHONY: run
run: $(MERLIN)
	@$(MERLIN) run $(if $(RELEASE),RELEASE=1,)

.PHONY: clean
clean: $(MERLIN)
	@$(MERLIN) clean $(if $(RELEASE),RELEASE=1,)

# Prevent catch-all from trying to build the Makefile itself
Makefile: ;

# Catch-all rule for VS Code Unity Test Extensions
%: $(MERLIN)
	@echo "[VS Code Extension Intercept] Building unified test suite via Merlin for target '$@'..."
	@$(MERLIN) test $(if $(RELEASE),RELEASE=1,)
	@cp bin/test_* $@$(if $(OS),.exe,) 2>nul || cp bin/test_* $@ 2>nul || cd .
