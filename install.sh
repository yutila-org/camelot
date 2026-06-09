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

mkdir -p "$CAMELOT_HOME/bin"
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; fi
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then ARCH="arm64"; fi

echo -e "\033[1;36m[DOWNLOAD] Fetching system-specific binary for Camelot ($OS-$ARCH)...\033[0m"
URL="https://github.com/yutila-org/camelot/releases/download/alpha/camelot-${OS}-${ARCH}"
if [[ "$OS" == *"mingw"* || "$OS" == *"msys"* || "$OS" == *"cygwin"* ]]; then
    URL="https://github.com/yutila-org/camelot/releases/download/alpha/camelot-windows-amd64.exe"
    curl -sSL "$URL" -o "$CAMELOT_HOME/bin/camelot.exe"
    chmod +x "$CAMELOT_HOME/bin/camelot.exe"
else
    curl -sSL "$URL" -o "$CAMELOT_HOME/bin/camelot"
    chmod +x "$CAMELOT_HOME/bin/camelot"
fi

SHELL_PROFILE=""
if [ -f "$HOME/.zshrc" ]; then SHELL_PROFILE="$HOME/.zshrc"; elif [ -f "$HOME/.bashrc" ]; then SHELL_PROFILE="$HOME/.bashrc"; fi

if [ -n "$SHELL_PROFILE" ]; then
    if ! grep -q "CAMELOT_HOME" "$SHELL_PROFILE"; then
        echo -e "\n# Camelot Framework" >> "$SHELL_PROFILE"
        echo -e "export CAMELOT_HOME=\"$CAMELOT_HOME\"" >> "$SHELL_PROFILE"
        echo -e "export PATH=\"\$CAMELOT_HOME/bin:\$PATH\"" >> "$SHELL_PROFILE"
    fi
fi

if ! command -v merlin &> /dev/null; then
    echo -e "\033[1;33m[NOTICE] Merlin build engine not found. Installing it now...\033[0m"
    curl -sSL https://github.com/yutila-org/merlin/releases/latest/download/install.sh | bash
fi

echo -e "\033[1;32m[SUCCESS] Camelot Framework installed to $CAMELOT_HOME!\033[0m"
