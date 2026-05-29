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
MERLIN_BIN := bin/merlin

.PHONY: default
default: $(MERLIN_BIN)
	@./$(MERLIN_BIN) all $(if $(RELEASE),RELEASE=1,)

$(MERLIN_BIN): merlin/*.d
	@mkdir bin 2>nul || true
	@echo -e "\033[1;38;5;198m( ๑•̀⩊•́๑ )\033[0m \033[36m< \"Bootstrapping standalone Merlin Build Engine...\"\033[0m"
	@dmd merlin/*.d -of=bin/merlin || (echo -e "\033[1;31mError: D compiler (dmd) not found or compilation failed! Please install dmd first.\033[0m"; exit 1)

.PHONY: all
all: $(MERLIN_BIN)
	@./$(MERLIN_BIN) all $(if $(RELEASE),RELEASE=1,)

.PHONY: test
test: $(MERLIN_BIN)
	@./$(MERLIN_BIN) test $(if $(RELEASE),RELEASE=1,)

.PHONY: run
run: $(MERLIN_BIN)
	@./$(MERLIN_BIN) run $(if $(RELEASE),RELEASE=1,)

.PHONY: clean
clean: $(MERLIN_BIN)
	@./$(MERLIN_BIN) clean $(if $(RELEASE),RELEASE=1,)
