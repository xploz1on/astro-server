#!/usr/bin/env bash
# lib/firewall.sh — UFW firewall configuration step
# Sourced by the main orchestrator; do NOT execute directly.
# Requires: lib/colors.sh, lib/os_detect.sh, lib/ui.sh sourced first.
# Globals read: DEFAULT_CONFIGURE_FIREWALL

configure_firewall() {
    if ask_yes_no "Configure UFW firewall?" "$DEFAULT_CONFIGURE_FIREWALL"; then
        print_step "7" "Configuring UFW Firewall"
        echo

        if ! command -v ufw &>/dev/null; then
            echo -e "${CYAN}Installing UFW...${NC}"
            local pid
            pkg_install ufw &
            pid=$!
            with_quips "$pid" &
            spinner "$pid"
            wait "$pid"
        fi

        print_warning "IMPORTANT: Make sure you have console access before enabling firewall!"
        print_warning "CRITICAL: Port 22 (SSH) will ALWAYS be preserved to maintain access!"

        if ask_yes_no "Continue with firewall configuration?" "y"; then
            echo -e "${CYAN}Configuring firewall rules...${NC}"

            sudo ufw --force reset > /dev/null 2>&1
            sudo ufw default deny incoming > /dev/null 2>&1
            sudo ufw default allow outgoing > /dev/null 2>&1

            # ── SSH — always allow port 22 first (cannot be locked out) ─────
            sudo ufw allow 22/tcp > /dev/null 2>&1
            sudo ufw limit 22/tcp > /dev/null 2>&1
            print_success "CRITICAL: SSH port 22 ALWAYS allowed and rate-limited"

            # Detect and allow custom SSH port if configured
            local ssh_port
            ssh_port=$(sudo sshd -T 2>/dev/null | awk '/^port / {print $2; exit}' || echo "22")
            if [ -n "$ssh_port" ] && [ "$ssh_port" != "22" ]; then
                sudo ufw allow "${ssh_port}/tcp" > /dev/null 2>&1
                sudo ufw limit "${ssh_port}/tcp" > /dev/null 2>&1
                print_info "Additional SSH port ${ssh_port} allowed"
            fi

            # Service-name backup rule
            sudo ufw allow ssh > /dev/null 2>&1 || true
            sudo ufw limit ssh > /dev/null 2>&1 || true
            print_info "SSH service rule added as backup"

            # ── Optional common ports ────────────────────────────────────────
            if ask_yes_no "Allow HTTP (port 80)?" "y"; then
                sudo ufw allow 80 > /dev/null 2>&1
            fi
            if ask_yes_no "Allow HTTPS (port 443)?" "y"; then
                sudo ufw allow 443 > /dev/null 2>&1
            fi

            # Custom ports
            if ask_yes_no "Add custom ports?" "n"; then
                echo -e "${YELLOW}Enter ports to allow (comma-separated, e.g., 8080,3000):${NC} \c"
                local custom_ports=""
                read -r custom_ports || custom_ports=""

                IFS=',' read -ra PORTS <<< "$custom_ports"
                for port in "${PORTS[@]}"; do
                    port=$(echo "$port" | tr -d ' ')
                    if [[ "$port" =~ ^[0-9]+$ ]]; then
                        sudo ufw allow "$port" > /dev/null 2>&1
                        print_info "Allowed port $port"
                    fi
                done
            fi

            # ── Enable and verify ────────────────────────────────────────────
            echo -e "${CYAN}Enabling firewall...${NC}"
            sudo ufw --force enable > /dev/null 2>&1

            echo -e "${CYAN}Verifying SSH access is maintained...${NC}"
            if sudo ufw status | grep -q "22.*ALLOW"; then
                print_success "SSH port 22 confirmed as ALLOWED"
            else
                print_error "WARNING: SSH port 22 not found in firewall rules!"
                print_warning "Emergency: Adding SSH port 22 manually..."
                sudo ufw allow 22/tcp > /dev/null 2>&1
                sudo ufw reload > /dev/null 2>&1
                print_success "SSH port 22 emergency-added and firewall reloaded"
            fi

            print_success "UFW firewall configured and enabled"
            print_warning "IMPORTANT: Test SSH access from another terminal before closing this session!"
        fi
    fi
}
