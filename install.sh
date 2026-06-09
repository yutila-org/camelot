#!/usr/bin/env bash
set -e

if ! command -v git &> /dev/null; then
    echo -e "\033[1;31m[ERROR] 'git' is not installed.\033[0m"
    exit 1
fi

CAMELOT_HOME="$HOME/.camelot"

if [ -d "$CAMELOT_HOME" ]; then
    echo -e "\033[1;36m[UPDATE] Updating Camelot in $CAMELOT_HOME...\033[0m"
    cd "$CAMELOT_HOME"
    git pull origin main
else
    echo -e "\033[1;36m[INSTALL] Cloning Camelot to $CAMELOT_HOME...\033[0m"
    git clone https://github.com/yutila-org/camelot.git "$CAMELOT_HOME"
fi

SHELL_PROFILE=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
fi

if [ -n "$SHELL_PROFILE" ]; then
    if ! grep -q "CAMELOT_HOME" "$SHELL_PROFILE"; then
        echo -e "\n# Camelot Framework Configuration" >> "$SHELL_PROFILE"
        echo -e "export CAMELOT_HOME=\"$CAMELOT_HOME\"" >> "$SHELL_PROFILE"
        echo -e "\033[1;32m[SUCCESS] Bound CAMELOT_HOME in $SHELL_PROFILE.\033[0m"
    fi
else
    echo -e "\033[1;33m[WARNING] Could not locate .bashrc or .zshrc. Please manually export CAMELOT_HOME=$CAMELOT_HOME\033[0m"
fi

if ! command -v merlin &> /dev/null; then
    echo -e "\033[1;33m[NOTICE] Merlin build engine not found. Installing it now...\033[0m"
    curl -sSL https://github.com/yutila-org/merlin/releases/latest/download/install.sh | bash
fi

echo -e "\033[1;32m[SUCCESS] Camelot Framework successfully initialized!\033[0m"
