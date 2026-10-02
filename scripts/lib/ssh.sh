#!/usr/bin/env bash
# lib/ssh.sh — SSH hardening step
# Sourced by the main orchestrator; do NOT execute directly.
# Requires: lib/colors.sh, lib/os_detect.sh, lib/ui.sh sourced first.
# Globals read: SSH_SERVICE, TMP_FILES (array), DEFAULT_HARDEN_SSH

harden_ssh() {
    if ask_yes_no "Harden SSH configuration?" "$DEFAULT_HARDEN_SSH"; then
        print_step "5" "Hardening SSH Configuration"
        echo

        # ── Key Management (SEC-001: never dump private key to stdout) ──────
        echo -e "${CYAN}Checking SSH key setup...${NC}"
        local has_local_key=0
        if [ -f ~/.ssh/id_rsa ] || [ -f ~/.ssh/id_ed25519 ] || [ -f ~/.ssh/id_ecdsa ]; then
            has_local_key=1
        fi

        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
        touch ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys

        if [ ! -s ~/.ssh/authorized_keys ]; then
            print_warning "No authorized public keys found in ~/.ssh/authorized_keys."
            print_info "To prevent lockout when passwords are disabled, an authorized key should be present."
            echo
            if ask_yes_no "Paste your client public key (e.g. from id_ed25519.pub) now?" "y"; then
                echo -e "${YELLOW}Paste your public key (single line starting with ssh-ed25519 or ssh-rsa):${NC}"
                local pasted_key=""
                read -rp "Key: " pasted_key || pasted_key=""
                if [[ "$pasted_key" =~ ^ssh-(ed25519|rsa|ecdsa) ]]; then
                    echo "$pasted_key" >> ~/.ssh/authorized_keys
                    chmod 600 ~/.ssh/authorized_keys
                    print_success "Public key added to ~/.ssh/authorized_keys"
                else
                    print_error "Invalid public key format provided. Skipped."
                fi
            fi
        fi

        if [ "$has_local_key" -eq 0 ]; then
            print_info "No SSH keypair found in ~/.ssh/ on this host."
            if ask_yes_no "Generate a dedicated ED25519 SSH keypair on this server?" "n"; then
                echo -e "${CYAN}Generating a new ED25519 SSH key...${NC}"
                ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C "$(whoami)@$(hostname)"
                chmod 600 ~/.ssh/id_ed25519
                chmod 644 ~/.ssh/id_ed25519.pub
                print_success "SSH key generated: ~/.ssh/id_ed25519 (private, mode 600) and ~/.ssh/id_ed25519.pub"
                print_info "For security, the private key is NOT printed to the terminal."
                print_info "To use this key remotely, copy it to your workstation securely (e.g., via scp or sftp)."

                if ! grep -qFf ~/.ssh/id_ed25519.pub ~/.ssh/authorized_keys 2>/dev/null; then
                    cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
                    chmod 600 ~/.ssh/authorized_keys
                    print_success "Generated public key added to ~/.ssh/authorized_keys"
                fi
            fi
        else
            print_success "Existing SSH key found for user $USER."
        fi

        # ── Backup (SEC-003: isolated directory, mode 0700/0600, 30-day prune) ──
        echo -e "${CYAN}Creating SSH configuration backup...${NC}"
        local backup_dir="/var/backups/astro-server"
        sudo install -d -m 0700 "$backup_dir"
        local backup_file="$backup_dir/sshd_config.backup.$(date +%Y%m%d_%H%M%S)"
        sudo cp /etc/ssh/sshd_config "$backup_file"
        sudo chmod 600 "$backup_file"
        sudo find "$backup_dir" -name "sshd_config.backup.*" -type f -mtime +30 -delete 2>/dev/null || true

        # ── Root login ───────────────────────────────────────────────────────
        if sudo grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
            echo -e "${CYAN}Disabling root login...${NC}"
            sudo sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
            print_success "Root login disabled"
        else
            print_info "Root login already disabled"
        fi

        # ── Hardening drop-in (SEC-004: HostKeyAlgorithms) ──────────────────
        sudo install -d -m 0755 /etc/ssh/sshd_config.d
        echo -e "${CYAN}Applying additional SSH security settings...${NC}"
        local ssh_tmp
        ssh_tmp=$(mktemp -t astro-ssh-XXXXXX)
        TMP_FILES+=("$ssh_tmp")

        cat > "$ssh_tmp" << 'EOF'
# SSH Security Hardening Configuration - Astro Server
HostKeyAlgorithms ssh-ed25519,rsa-sha2-512,rsa-sha2-256
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
MaxAuthTries 3
MaxSessions 2
LoginGraceTime 30
PermitEmptyPasswords no
Protocol 2
HostbasedAuthentication no
IgnoreRhosts yes
ClientAliveInterval 300
ClientAliveCountMax 2
AllowTcpForwarding yes
GatewayPorts no
AllowAgentForwarding no
StrictModes yes
Compression no
X11Forwarding no
EOF

        sudo cp "$ssh_tmp" /etc/ssh/sshd_config.d/99-security-hardening.conf
        sudo chmod 644 /etc/ssh/sshd_config.d/99-security-hardening.conf
        rm -f "$ssh_tmp"

        # ── Validate + reload (LINUX-004: dynamic SSH_SERVICE) ───────────────
        if sudo sshd -t; then
            sudo systemctl reload "$SSH_SERVICE" 2>/dev/null || sudo systemctl restart "$SSH_SERVICE"
            print_success "SSH hardening applied successfully (reloaded $SSH_SERVICE)"
        else
            print_error "SSH configuration test failed, reverting changes"
            sudo rm -f /etc/ssh/sshd_config.d/99-security-hardening.conf
            sudo cp "$backup_file" /etc/ssh/sshd_config
            sudo systemctl reload "$SSH_SERVICE" 2>/dev/null || true
        fi
    fi
}
