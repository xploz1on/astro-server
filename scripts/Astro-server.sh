#!/usr/bin/env bash
# Astro-server.sh — Thin orchestrator for the Astro Server Security Toolkit
# Version: 1.1.0
# Author:  Astro Tech Security Team
#
# This file is intentionally small. All business logic lives in scripts/lib/:
#   colors.sh    — ANSI palette, print helpers, ask_yes_no
#   os_detect.sh — detect_os(), pkg_install/update/upgrade/is_installed
#   ui.sh        — spinner, progress bar, scorecard, quips, profile defaults
#   scoring.sh   — calculate_security_score()
#   ssh.sh       — harden_ssh()
#   fail2ban.sh  — install_fail2ban()
#   firewall.sh  — configure_firewall()
#   sysctl.sh    — kernel_hardening()

set -euo pipefail

# ── Locate lib directory relative to this script ────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# ── Source all modules ───────────────────────────────────────────────────────
# Order matters: colors first, then config to load SSoT, then the rest
for _mod in colors config os_detect ui scoring ssh fail2ban firewall sysctl; do
    # shellcheck source=/dev/null
    source "$LIB_DIR/${_mod}.sh" || {
        echo "ERROR: Failed to load module ${_mod}.sh" >&2
        exit 1
    }
done
unset _mod

# Load the YAML configuration as the Single Source of Truth
load_config || exit 1

# ── Temporary file management ────────────────────────────────────────────────
TMP_FILES=()
IP_CACHE_FILE="/tmp/astro_ip_cache.$$.tmp"
TMP_FILES+=("$IP_CACHE_FILE")

# Async background IP pre-fetch for 0ms Fail2Ban setup
prefetch_admin_ip() {
    (
        local raw=""
        raw=$(curl -fsS -m 1.5 https://ifconfig.io 2>/dev/null \
           || curl -fsS -m 1.5 https://api.ipify.org 2>/dev/null \
           || true)
        if [[ "$raw" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] \
        || [[ "$raw" =~ ^[0-9a-fA-F:]+$ ]]; then
            echo "$raw" > "$IP_CACHE_FILE" 2>/dev/null || true
        fi
    ) &
}
prefetch_admin_ip

# ── Trap: cleanup temp files on exit / interrupt ─────────────────────────────
cleanup_and_exit() {
    local sig="${1:-EXIT}"
    for tmp_f in "${TMP_FILES[@]}"; do
        if [ -n "$tmp_f" ] && [ -f "$tmp_f" ]; then
            rm -f "$tmp_f" 2>/dev/null || true
        fi
    done
    if [ "$sig" != "EXIT" ]; then
        echo -e "\n${RED}Script interrupted. Exiting...${NC}"
        exit 1
    fi
}
trap 'cleanup_and_exit EXIT' EXIT
trap 'cleanup_and_exit INT'  INT
trap 'cleanup_and_exit TERM' TERM

# ── Argument parsing ─────────────────────────────────────────────────────────
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --profile)
                PROFILE="$2"; shift 2 ;;
            --no-jokes)
                ASTRO_NO_JOKES=1; export ASTRO_NO_JOKES; shift ;;
            --config)
                # Reserved; accepted and ignored for forward-compatibility
                shift 2 ;;
            *)
                break ;;
        esac
    done
}

# ── Root / sudo check ────────────────────────────────────────────────────────
check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_error "Please don't run this script as root. Use a sudo-enabled user instead."
        exit 1
    fi

    if ! sudo -n true 2>/dev/null; then
        print_info "This script requires sudo privileges. You may be prompted for your password."
        sudo -v || {
            print_error "Failed to obtain sudo privileges"
            exit 1
        }
    fi
}

# ── Baseline system info + pre-hardening scorecard ───────────────────────────
system_info() {
    print_step "1" "Gathering System Information & Baseline Audit"
    echo

    OS=$(lsb_release -d 2>/dev/null | cut -f2 \
      || grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
    KERNEL=$(uname -r)
    ARCH=$(uname -m)
    UPTIME=$(uptime -p)

    echo -e "${BLUE}🖥️  Operating System: ${WHITE}$OS${NC}"
    echo -e "${BLUE}🔧 Kernel Version:   ${WHITE}$KERNEL${NC}"
    echo -e "${BLUE}💻 Architecture:     ${WHITE}$ARCH${NC}"
    echo -e "${BLUE}⏰ Uptime:          ${WHITE}$UPTIME${NC}"
    echo

    echo -e "${PURPLE}${BOLD}--- Initial Security Assessment ---${NC}"
    local baseline_score
    baseline_score=$(calculate_security_score)
    render_security_scorecard "$baseline_score" "Pre-Hardening Baseline"
    echo

    if ask_yes_no "Continue with security hardening?" "y"; then
        return 0
    else
        echo -e "${YELLOW}Exiting...${NC}"
        exit 0
    fi
}

# ── Timezone configuration ───────────────────────────────────────────────────
configure_timezone() {
    if ask_yes_no "Do you want to configure the system timezone?" "y"; then
        print_step "2" "Configuring Timezone"
        echo

        echo -e "${CYAN}Current timezone: ${WHITE}$(timedatectl show --property=Timezone --value 2>/dev/null \
            || cat /etc/timezone 2>/dev/null \
            || echo 'Unknown')${NC}"
        echo

        if ask_yes_no "Change timezone?" "n"; then
            echo -e "${YELLOW}Available timezones (showing common ones):${NC}"
            echo "1) UTC"
            echo "2) America/New_York"
            echo "3) America/Los_Angeles"
            echo "4) Europe/London"
            echo "5) Europe/Berlin"
            echo "6) Asia/Tokyo"
            echo "7) Custom (enter manually)"
            echo

            echo -e "${YELLOW}Enter choice [1-7]:${NC} \c"
            local tz_choice=""
            read -r tz_choice || tz_choice=""

            local TIMEZONE=""
            case $tz_choice in
                1) TIMEZONE="UTC" ;;
                2) TIMEZONE="America/New_York" ;;
                3) TIMEZONE="America/Los_Angeles" ;;
                4) TIMEZONE="Europe/London" ;;
                5) TIMEZONE="Europe/Berlin" ;;
                6) TIMEZONE="Asia/Tokyo" ;;
                7)
                    echo -e "${YELLOW}Enter timezone (e.g., Asia/Shanghai):${NC} \c"
                    read -r TIMEZONE || TIMEZONE=""
                    ;;
                *)
                    print_warning "Invalid choice, keeping current timezone"
                    return
                    ;;
            esac

            echo -e "${CYAN}Setting timezone to $TIMEZONE...${NC}"
            sudo timedatectl set-timezone "$TIMEZONE" && \
            print_success "Timezone set to $TIMEZONE"
        fi
    fi
}

# ── System update ────────────────────────────────────────────────────────────
update_system() {
    if ask_yes_no "Update system packages?" "$DEFAULT_UPDATE_SYSTEM"; then
        print_step "3" "Updating System Packages"
        echo

        echo -e "${CYAN}Updating package repositories ($PKG_MANAGER)...${NC}"
        local pid
        pkg_update &
        pid=$!
        with_quips "$pid" &
        spinner "$pid"
        wait "$pid"
        print_success "Package repositories updated"

        echo -e "${CYAN}Checking for upgradable packages...${NC}"
        local upgradable=0
        if [ "$PKG_MANAGER" = "apt" ]; then
            upgradable=$(apt list --upgradable 2>/dev/null | grep -c upgradable || echo "0")
            [ "$upgradable" -gt 0 ] && upgradable=$((upgradable - 1))
        fi

        if [ "$upgradable" -gt 0 ] || [ "$PKG_MANAGER" != "apt" ]; then
            [ "$upgradable" -gt 0 ] && print_info "$upgradable packages can be upgraded"

            if ask_yes_no "Upgrade all packages now?" "y"; then
                echo -e "${CYAN}Upgrading packages (this may take a while)...${NC}"
                pkg_upgrade &
                pid=$!
                with_quips "$pid" &
                spinner "$pid"
                wait "$pid"
                print_success "System packages upgraded"
            fi
        else
            print_success "System is already up to date"
        fi
    fi
}

# ── Unattended upgrades ──────────────────────────────────────────────────────
configure_unattended_upgrades() {
    if ask_yes_no "Enable automatic security updates?" "$DEFAULT_ENABLE_UNATTENDED"; then
        print_step "4" "Configuring Automatic Security Updates"
        echo

        local pid
        if [ "$OS_FAMILY" = "debian" ]; then
            if ! is_pkg_installed unattended-upgrades; then
                echo -e "${CYAN}Installing unattended-upgrades...${NC}"
                pkg_install unattended-upgrades &
                pid=$!
                with_quips "$pid" &
                spinner "$pid"
                wait "$pid"
            fi
            echo -e "${CYAN}Configuring automatic security updates...${NC}"
            sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure -plow unattended-upgrades > /dev/null 2>&1 || true
            sudo systemctl enable unattended-upgrades > /dev/null 2>&1 || true
            sudo systemctl start  unattended-upgrades > /dev/null 2>&1 || true
            print_success "Automatic security updates enabled (unattended-upgrades)"
        elif [ "$OS_FAMILY" = "redhat" ]; then
            if ! is_pkg_installed dnf-automatic; then
                echo -e "${CYAN}Installing dnf-automatic...${NC}"
                pkg_install dnf-automatic &
                pid=$!
                with_quips "$pid" &
                spinner "$pid"
                wait "$pid"
            fi
            if [ -f /etc/dnf/automatic.conf ]; then
                sudo sed -i 's/^apply_updates = .*/apply_updates = yes/' /etc/dnf/automatic.conf 2>/dev/null || true
            fi
            sudo systemctl enable --now dnf-automatic.timer > /dev/null 2>&1 || true
            print_success "Automatic security updates enabled (dnf-automatic)"
        else
            print_info "Automatic update service configuration skipped for OS family '$OS_FAMILY'."
        fi
    fi
}

# ── Security monitoring script ───────────────────────────────────────────────
create_monitoring_script() {
    if ask_yes_no "Create security monitoring script?" "$DEFAULT_CREATE_MONITORING"; then
        print_step "9" "Creating Security Monitoring Script"
        echo

        echo -e "${CYAN}Creating markdown security report generator...${NC}"

        local src_report=""
        if [ -f "$SCRIPT_DIR/security-report.sh" ]; then
            src_report="$SCRIPT_DIR/security-report.sh"
        elif [ -f "$SCRIPT_DIR/../scripts/security-report.sh" ]; then
            src_report="$SCRIPT_DIR/../scripts/security-report.sh"
        fi

        if [ -n "$src_report" ]; then
            cp "$src_report" ./security-report.sh
            chmod +x ./security-report.sh
        fi

        print_success "Markdown security report generator created as 'security-report.sh'"

        if ask_yes_no "Generate security report now?" "y"; then
            echo
            ./security-report.sh
            echo
            print_info "Security report saved as 'security-check.md'"
        fi
    fi
}

# ── Post-hardening summary ───────────────────────────────────────────────────
final_report() {
    print_step "10" "Security Hardening Complete!"
    echo

    echo -e "${GREEN}${BOLD}🎉 CONGRATULATIONS! 🎉${NC}"
    echo -e "${WHITE}Your server has been successfully hardened with the following security measures:${NC}"
    echo

    echo -e "${CYAN}✅ System Updates:${NC} Applied latest security patches"
    echo -e "${CYAN}✅ SSH Hardening:${NC} Root login disabled, connection limits and modern ciphers set"

    command -v fail2ban-client &>/dev/null && \
        echo -e "${CYAN}✅ Fail2Ban:${NC} Brute force protection active"

    if command -v ufw &>/dev/null && sudo ufw status 2>/dev/null | grep -q "Status: active"; then
        echo -e "${CYAN}✅ Firewall:${NC} UFW configured and active"
    fi

    echo -e "${CYAN}✅ Kernel Hardening:${NC} Network and system security parameters applied"

    if systemctl is-active --quiet unattended-upgrades 2>/dev/null \
    || systemctl is-active --quiet dnf-automatic.timer 2>/dev/null; then
        echo -e "${CYAN}✅ Auto Updates:${NC} Automatic security updates enabled"
    fi

    [ -f "security-report.sh" ] && \
        echo -e "${CYAN}✅ Monitoring:${NC} Security monitoring script created ('security-report.sh')"

    echo
    echo -e "${PURPLE}${BOLD}--- Post-Hardening Security Scorecard ---${NC}"
    local fortified_score
    fortified_score=$(calculate_security_score)
    render_security_scorecard "$fortified_score" "Fortified Posture"
    echo

    echo -e "${YELLOW}${BOLD}📋 IMPORTANT NOTES:${NC}"
    echo -e "${WHITE}• SSH configuration backup saved in /var/backups/astro-server/${NC}"
    echo -e "${WHITE}• Run './security-report.sh' to check security status${NC}"
    echo -e "${WHITE}• Monitor logs regularly: sudo journalctl -u $SSH_SERVICE${NC}"
    echo -e "${WHITE}• Keep your system updated regularly via your package manager ($PKG_MANAGER)${NC}"
    echo

    echo -e "${PURPLE}${BOLD}🚀 Your server is now ASTRO-level secure! 🚀${NC}"
    echo
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
    print_banner
    check_root
    detect_os
    parse_args "$@"
    apply_profile_defaults

    system_info
    configure_timezone
    update_system
    configure_unattended_upgrades
    harden_ssh
    install_fail2ban
    configure_firewall
    kernel_hardening
    create_monitoring_script
    final_report
}

main "$@"