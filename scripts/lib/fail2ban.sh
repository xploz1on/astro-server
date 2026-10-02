#!/usr/bin/env bash
# lib/fail2ban.sh — Fail2Ban installation and configuration step
# Sourced by the main orchestrator; do NOT execute directly.
# Requires: lib/colors.sh, lib/os_detect.sh, lib/ui.sh sourced first.
# Globals read: IP_CACHE_FILE, TMP_FILES (array), DEFAULT_INSTALL_FAIL2BAN

install_fail2ban() {
    if ask_yes_no "Install and configure Fail2Ban for brute force protection?" "$DEFAULT_INSTALL_FAIL2BAN"; then
        print_step "6" "Installing and Configuring Fail2Ban"
        echo

        if ! command -v fail2ban-client &>/dev/null; then
            echo -e "${CYAN}Installing Fail2Ban...${NC}"
            local pid
            pkg_install fail2ban &
            pid=$!
            with_quips "$pid" &
            spinner "$pid"
            wait "$pid"
        fi

        echo -e "${CYAN}Configuring Fail2Ban with aggressive settings...${NC}"

        # ── Ban duration selection ───────────────────────────────────────────
        echo -e "${YELLOW}Choose ban duration for SSH attacks:${NC}"
        echo "1) 1 hour (3600 seconds)"
        echo "2) 6 hours (21600 seconds)"
        echo "3) 24 hours (86400 seconds) - Recommended"
        echo "4) 1 week (604800 seconds)"
        echo
        echo -e "${YELLOW}Enter choice [1-4]:${NC} \c"
        local ban_choice=""
        read -r ban_choice || ban_choice="3"

        local BAN_TIME
        case $ban_choice in
            1) BAN_TIME=3600 ;;
            2) BAN_TIME=21600 ;;
            3) BAN_TIME=86400 ;;
            4) BAN_TIME=604800 ;;
            *) BAN_TIME=86400 ;;
        esac

        # ── Admin IP fetch (SEC-002: strict format validation) ───────────────
        local raw_ip="" admin_ip=""
        if [[ -f "${IP_CACHE_FILE:-}" ]]; then
            raw_ip=$(cat "$IP_CACHE_FILE" 2>/dev/null || true)
        fi
        if [[ -z "$raw_ip" ]]; then
            raw_ip=$(curl -fsS --max-time 3 https://ifconfig.io 2>/dev/null \
                  || curl -fsS --max-time 3 https://api.ipify.org 2>/dev/null \
                  || true)
        fi
        # Strict IPv4 or IPv6 validation before use
        if [[ "$raw_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] \
        || [[ "$raw_ip" =~ ^[0-9a-fA-F:]+$ ]]; then
            admin_ip="$raw_ip"
        fi

        # ── Write jail.local via secure temp file (BASH-002) ─────────────────
        local jail_tmp
        jail_tmp=$(mktemp -t astro-jail-XXXXXX)
        TMP_FILES+=("$jail_tmp")

        cat > "$jail_tmp" << EOF
[DEFAULT]
bantime = $BAN_TIME
findtime = 600
maxretry = 3
ignoreip = 127.0.0.1/8 ::1 ${admin_ip}

[sshd]
enabled = true
mode = aggressive
bantime = $BAN_TIME
findtime = 300
maxretry = 3
EOF

        sudo cp "$jail_tmp" /etc/fail2ban/jail.local
        sudo chmod 644 /etc/fail2ban/jail.local
        rm -f "$jail_tmp"

        sudo systemctl enable fail2ban > /dev/null 2>&1 || true
        sudo systemctl restart fail2ban > /dev/null 2>&1 || true

        print_success "Fail2Ban configured with $((BAN_TIME / 3600)) hour ban time"
    fi
}
