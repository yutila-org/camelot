#!/usr/bin/env bash
set -e

# Dependency Verification
if ! command -v clang &> /dev/null; then
    echo -e "\033[1;31m[ERROR] 'clang' is not installed.\033[0m"
    echo -e "Please install it using your package manager (e.g., 'sudo apt install clang' or 'brew install llvm')."
    exit 1
fi

if ! command -v dmd &> /dev/null; then
    echo -e "\033[1;31m[ERROR] 'dmd' (D compiler) is not installed.\033[0m"
    echo -e "Please install it seamlessly via: \033[1;36mcurl -fsS https://dlang.org/install.sh | bash -s dmd\033[0m"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo -e "\033[1;31m[ERROR] 'git' is not installed. Please install git.\033[0m"
    exit 1
fi

CAMELOT_HOME="$HOME/.camelot"

if [ -d "$CAMELOT_HOME" ]; then
    echo -e "\033[1;36m[UPDATE] Updating existing Camelot installation in $CAMELOT_HOME...\033[0m"
    cd "$CAMELOT_HOME"
    git pull origin main
else
    echo -e "\033[1;36m[INSTALL] Cloning Camelot to $CAMELOT_HOME...\033[0m"
    git clone https://github.com/yutila-org/camelot.git "$CAMELOT_HOME"
    cd "$CAMELOT_HOME"
fi

echo -e "\033[1;36m[BUILD] Compiling Merlin Engine via dmd...\033[0m"
mkdir -p bin
dmd merlin/*.d -of=bin/merlin

# Dynamic shell profile patching
SHELL_PROFILE=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
fi

if [ -n "$SHELL_PROFILE" ]; then
    if ! grep -q "CAMELOT_HOME" "$SHELL_PROFILE"; then
        echo -e "\n# Camelot & Merlin Framework Configuration" >> "$SHELL_PROFILE"
        echo -e "export CAMELOT_HOME=\"$CAMELOT_HOME\"" >> "$SHELL_PROFILE"
        echo -e "export PATH=\"\$CAMELOT_HOME/bin:\$PATH\"" >> "$SHELL_PROFILE"
        echo -e "\033[1;32m[SUCCESS] Bound CAMELOT_HOME and added Merlin to $SHELL_PROFILE.\033[0m"
    fi
else
    echo -e "\033[1;33m[WARNING] Could not locate .bashrc or .zshrc. Please manually export CAMELOT_HOME=$CAMELOT_HOME and append \$CAMELOT_HOME/bin to your PATH.\033[0m"
fi

echo -e "\033[1;32m[SUCCESS] Camelot Framework and Merlin Engine successfully initialized!\033[0m"
echo -e "Please restart your terminal or run \033[1;36msource $SHELL_PROFILE\033[0m to wield 'merlin'."
