#!/usr/bin/env bash
# scripts/rollback.sh — Astro Server Rollback Tool
# Safely reverts security hardening applied by Astro Server.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# Load modules
source "$LIB_DIR/colors.sh"
source "$LIB_DIR/os_detect.sh"
source "$LIB_DIR/ui.sh"

detect_os

echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║                 🔄 ASTRO SERVER ROLLBACK TOOL                 ║${NC}"
echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo

print_warning "This will revert the security configurations applied by Astro Server."
print_warning "Packages installed (e.g., fail2ban, ufw) will NOT be uninstalled, but their Astro configs will be removed."
echo
if ! ask_yes_no "Are you sure you want to proceed with rollback?" "n"; then
    echo -e "${YELLOW}Rollback cancelled.${NC}"
    exit 0
fi

echo -e "${CYAN}Starting rollback sequence...${NC}"

# 1. SSH Rollback
echo -e "\n${BOLD}[1/4] SSH Configuration${NC}"
if [ -f /etc/ssh/sshd_config.d/99-security-hardening.conf ]; then
    echo -e "  Removing Astro SSH drop-in configuration..."
    sudo rm -f /etc/ssh/sshd_config.d/99-security-hardening.conf
else
    echo -e "  No Astro SSH drop-in configuration found."
fi

BACKUP_DIR="/var/backups/astro-server"
if [ -d "$BACKUP_DIR" ]; then
    LATEST_BACKUP=$(find "$BACKUP_DIR" -name "sshd_config.backup.*" -type f | sort -V | tail -n 1)
    if [ -n "$LATEST_BACKUP" ]; then
        if ask_yes_no "Restore main sshd_config from latest backup ($LATEST_BACKUP)?" "y"; then
            sudo cp "$LATEST_BACKUP" /etc/ssh/sshd_config
            print_success "Restored /etc/ssh/sshd_config from backup."
        else
            echo -e "  Skipping main sshd_config restoration."
        fi
    else
        echo -e "  ${YELLOW}No SSH backups found in $BACKUP_DIR.${NC}"
    fi
else
    echo -e "  ${YELLOW}No backup directory ($BACKUP_DIR) found.${NC}"
fi

echo -e "  Reloading SSH service ($SSH_SERVICE)..."
sudo systemctl reload "$SSH_SERVICE" 2>/dev/null || sudo systemctl restart "$SSH_SERVICE" || print_warning "Failed to reload SSH service. You may need to restart it manually."

# 2. Kernel/Sysctl Rollback
echo -e "\n${BOLD}[2/4] Kernel Parameters (sysctl)${NC}"
if [ -f /etc/sysctl.d/99-security.conf ]; then
    echo -e "  Removing Astro sysctl configuration..."
    sudo rm -f /etc/sysctl.d/99-security.conf
    echo -e "  Reloading system defaults..."
    sudo sysctl --system > /dev/null 2>&1 || true
    print_success "Kernel parameters rolled back."
else
    echo -e "  No Astro sysctl configuration found."
fi

# 3. Fail2Ban Rollback
echo -e "\n${BOLD}[3/4] Fail2Ban Configuration${NC}"
if [ -f /etc/fail2ban/jail.local ]; then
    if ask_yes_no "Remove Fail2Ban jail.local (this will disable Astro's Fail2Ban jails)?" "y"; then
        sudo rm -f /etc/fail2ban/jail.local
        if systemctl is-active --quiet fail2ban; then
            echo -e "  Restarting Fail2Ban..."
            sudo systemctl restart fail2ban > /dev/null 2>&1 || true
        fi
        print_success "Fail2Ban configuration removed."
    else
        echo -e "  Skipping Fail2Ban rollback."
    fi
else
    echo -e "  No Fail2Ban jail.local found."
fi

# 4. Firewall Rollback
echo -e "\n${BOLD}[4/4] Firewall Configuration${NC}"
if command -v ufw >/dev/null 2>&1 && sudo ufw status | grep -q "Status: active"; then
    if ask_yes_no "UFW firewall is active. Disable and reset UFW?" "n"; then
        sudo ufw disable > /dev/null 2>&1
        sudo ufw --force reset > /dev/null 2>&1
        print_success "UFW disabled and reset."
    else
        echo -e "  Skipping UFW rollback."
    fi
elif command -v firewall-cmd >/dev/null 2>&1 && sudo firewall-cmd --state >/dev/null 2>&1; then
    if ask_yes_no "Firewalld is active. Stop and disable Firewalld?" "n"; then
        sudo systemctl stop firewalld > /dev/null 2>&1
        sudo systemctl disable firewalld > /dev/null 2>&1
        print_success "Firewalld stopped and disabled."
    else
        echo -e "  Skipping Firewalld rollback."
    fi
else
    echo -e "  No active supported firewall detected."
fi

echo
echo -e "${GREEN}${BOLD}✅ Rollback complete.${NC}"
echo -e "${YELLOW}Note: Packages installed during hardening (like fail2ban or unattended-upgrades) were left intact to avoid breaking dependencies.${NC}"
