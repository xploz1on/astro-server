#!/usr/bin/env bash
# Astro Server - Zero-dependency Installer
# Usage: curl -sSL https://raw.githubusercontent.com/xploz1on/astro-server/main/install.sh | sudo bash

set -euo pipefail

REPO="xploz1on/astro-server"
INSTALL_DIR="/opt/astro-server"
BIN_DIR="/usr/local/bin"
BRANCH="main"
TAR_URL="https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz"

echo -e "\033[0;36m🚀 Installing Astro Server Security Toolkit...\033[0m"

# Require root for global install
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[0;31m❌ Please run the installer as root (e.g. sudo bash)\033[0m"
    exit 1
fi

# Ensure curl and tar are available
if ! command -v curl >/dev/null 2>&1; then
    echo -e "\033[0;31m❌ curl is required to download Astro Server.\033[0m"
    exit 1
fi

if ! command -v tar >/dev/null 2>&1; then
    echo -e "\033[0;31m❌ tar is required to extract Astro Server.\033[0m"
    exit 1
fi

echo -e "📦 Downloading toolkit from $REPO..."
mkdir -p "$INSTALL_DIR"
curl -sSL "$TAR_URL" | tar -xz -C "$INSTALL_DIR" --strip-components=1

echo -e "🔗 Setting permissions and linking to $BIN_DIR/astro..."
chmod +x "$INSTALL_DIR/astro"
find "$INSTALL_DIR/scripts" -type f -name "*.sh" -exec chmod +x {} \;

mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/astro" "$BIN_DIR/astro"

echo
echo -e "\033[0;32m✅ Installation complete!\033[0m"
echo -e "\033[0;33m💡 You can now run 'astro' from anywhere in your terminal.\033[0m"
