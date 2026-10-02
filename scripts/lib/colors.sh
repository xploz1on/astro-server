#!/usr/bin/env bash
# lib/colors.sh — ANSI color palette and print helpers
# Sourced by the main orchestrator; do NOT execute directly.

# ── Color palette ────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ── Print helpers ────────────────────────────────────────────────────────────
print_success() { echo -e "${GREEN}${BOLD}✅ SUCCESS:${NC} $1"; }
print_warning() { echo -e "${YELLOW}${BOLD}⚠️  WARNING:${NC} $1"; }
print_error()   { echo -e "${RED}${BOLD}❌ ERROR:${NC} $1"; }
print_info()    { echo -e "${BLUE}${BOLD}ℹ️  INFO:${NC} $1"; }

print_banner() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "    ╔═══════════════════════════════════════════════════════════════╗"
    echo "    ║                                                               ║"
    echo "    ║      🚀 ASTRO SERVER SECURITY HARDENING TOOL 🚀              ║"
    echo "    ║                                                               ║"
    echo "    ║           Transform your server into a fortress!              ║"
    echo "    ║                                                               ║"
    echo "    ╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
}

ask_yes_no() {
    local question="$1"
    local default="$2"
    local response=""

    if [ "$default" = "y" ]; then
        echo -e "${YELLOW}${BOLD}❓ $question [Y/n]:${NC} \c"
    else
        echo -e "${YELLOW}${BOLD}❓ $question [y/N]:${NC} \c"
    fi

    read -r response || response=""
    [ -z "$response" ] && response="$default"

    case "$response" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}
