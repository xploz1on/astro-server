#!/usr/bin/env bash
# lib/os_detect.sh — OS/distribution detection and package manager abstraction
# Sourced by the main orchestrator; do NOT execute directly.
# Requires: lib/colors.sh sourced first (for print_warning/print_error).

# ── Globals populated by detect_os() ────────────────────────────────────────
OS_FAMILY="unknown"
PKG_MANAGER="unknown"
SSH_SERVICE="sshd"

# ── Distribution detection ───────────────────────────────────────────────────
detect_os() {
    local os_id="" os_like=""
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        os_id="${ID:-unknown}"
        os_like="${ID_LIKE:-}"
    fi

    if [[ "$os_id" =~ ^(ubuntu|debian|kali|pop|linuxmint)$ ]] || [[ "$os_like" =~ (debian|ubuntu) ]]; then
        OS_FAMILY="debian"
        PKG_MANAGER="apt"
        SSH_SERVICE="ssh"
    elif [[ "$os_id" =~ ^(rhel|centos|fedora|rocky|almalinux|ol)$ ]] || [[ "$os_like" =~ (rhel|fedora|centos) ]]; then
        OS_FAMILY="redhat"
        PKG_MANAGER=$(command -v dnf &>/dev/null && echo "dnf" || echo "yum")
        SSH_SERVICE="sshd"
    elif [[ "$os_id" =~ ^(arch|manjaro|endeavouros)$ ]] || [[ "$os_like" =~ arch ]]; then
        OS_FAMILY="arch"
        PKG_MANAGER="pacman"
        SSH_SERVICE="sshd"
    else
        OS_FAMILY="linux"
        PKG_MANAGER="unknown"
        SSH_SERVICE="sshd"
    fi

    # Verify SSH service name dynamically via systemd
    if command -v systemctl &>/dev/null; then
        if systemctl list-unit-files sshd.service 2>/dev/null | grep -q sshd.service; then
            SSH_SERVICE="sshd"
        elif systemctl list-unit-files ssh.service 2>/dev/null | grep -q ssh.service; then
            SSH_SERVICE="ssh"
        fi
    fi
}

# ── Package manager abstraction ──────────────────────────────────────────────
pkg_update() {
    case "$PKG_MANAGER" in
        apt)         sudo apt update > /dev/null 2>&1 ;;
        dnf|yum)     sudo "$PKG_MANAGER" check-update > /dev/null 2>&1 || true ;;
        pacman)      sudo pacman -Sy > /dev/null 2>&1 ;;
        *)           print_warning "Unknown package manager ($PKG_MANAGER); skipping repo update." ;;
    esac
}

pkg_upgrade() {
    case "$PKG_MANAGER" in
        apt)         sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y > /dev/null 2>&1 ;;
        dnf|yum)     sudo "$PKG_MANAGER" upgrade -y > /dev/null 2>&1 ;;
        pacman)      sudo pacman -Syu --noconfirm > /dev/null 2>&1 ;;
        *)           print_warning "Unknown package manager ($PKG_MANAGER); skipping upgrade." ;;
    esac
}

pkg_install() {
    local pkgs=("$@")
    case "$PKG_MANAGER" in
        apt)         sudo DEBIAN_FRONTEND=noninteractive apt install -y "${pkgs[@]}" > /dev/null 2>&1 ;;
        dnf|yum)     sudo "$PKG_MANAGER" install -y "${pkgs[@]}" > /dev/null 2>&1 ;;
        pacman)      sudo pacman -S --noconfirm "${pkgs[@]}" > /dev/null 2>&1 ;;
        *)           print_error "Cannot install packages: unsupported package manager $PKG_MANAGER" ;;
    esac
}

is_pkg_installed() {
    local pkg="$1"
    case "$PKG_MANAGER" in
        apt)         dpkg -s "$pkg" 2>/dev/null | grep -q "Status: install ok installed" ;;
        dnf|yum)     rpm -q "$pkg" > /dev/null 2>&1 ;;
        pacman)      pacman -Q "$pkg" > /dev/null 2>&1 ;;
        *)           command -v "$pkg" > /dev/null 2>&1 ;;
    esac
}
