#!/usr/bin/env bash
# lib/sysctl.sh — Kernel security hardening step
# Sourced by the main orchestrator; do NOT execute directly.
# Requires: lib/colors.sh, lib/ui.sh sourced first.
# Globals read: DEFAULT_KERNEL_HARDEN, TMP_FILES (array)

kernel_hardening() {
    if ask_yes_no "Apply kernel security hardening?" "$DEFAULT_KERNEL_HARDEN"; then
        print_step "8" "Applying Kernel Security Hardening"
        echo

        echo -e "${CYAN}Configuring kernel security parameters...${NC}"

        # ── Decide on IPv6 ───────────────────────────────────────────────────
        local ipv6_ssh_listen=0
        if ss -tlpn 2>/dev/null | grep -q ':::22'; then
            ipv6_ssh_listen=1
        fi

        local DISABLE_IPV6="n"
        if [ "$ipv6_ssh_listen" -eq 1 ]; then
            print_warning "IPv6 SSH detected; skipping IPv6 disable by default."
            if ask_yes_no "Force disable IPv6 anyway?" "n"; then DISABLE_IPV6="y"; fi
        else
            if ask_yes_no "Disable IPv6 networking (recommended on IPv4-only hosts)?" "n"; then DISABLE_IPV6="y"; fi
        fi

        # ── Write sysctl config via secure temp file (BASH-002) ──────────────
        local sysctl_tmp
        sysctl_tmp=$(mktemp -t astro-sysctl-XXXXXX)
        TMP_FILES+=("$sysctl_tmp")

        cat > "$sysctl_tmp" << EOF
# Astro Server - Kernel Security Hardening Configuration
# Generated from Single-Source-of-Truth YAML config

# ── Network forwarding & redirects ───────────────────────────────────────────
net.ipv4.ip_forward = \${CONF_kernel_security_network_ip_forward:-0}
net.ipv6.conf.all.forwarding = 0
net.ipv4.conf.all.send_redirects = \${CONF_kernel_security_network_send_redirects:-0}
net.ipv4.conf.default.send_redirects = \${CONF_kernel_security_network_send_redirects:-0}
net.ipv4.conf.all.accept_redirects = \${CONF_kernel_security_network_accept_redirects:-0}
net.ipv4.conf.default.accept_redirects = \${CONF_kernel_security_network_accept_redirects:-0}
net.ipv6.conf.all.accept_redirects = \${CONF_kernel_security_network_accept_redirects:-0}
net.ipv6.conf.default.accept_redirects = \${CONF_kernel_security_network_accept_redirects:-0}
net.ipv4.conf.all.accept_source_route = \${CONF_kernel_security_network_accept_source_route:-0}
net.ipv4.conf.default.accept_source_route = \${CONF_kernel_security_network_accept_source_route:-0}
net.ipv6.conf.all.accept_source_route = \${CONF_kernel_security_network_accept_source_route:-0}
net.ipv6.conf.default.accept_source_route = \${CONF_kernel_security_network_accept_source_route:-0}

# ── Reverse path filtering & martian logging ─────────────────────────────────
net.ipv4.conf.all.rp_filter = \${CONF_kernel_security_network_rp_filter:-1}
net.ipv4.conf.default.rp_filter = \${CONF_kernel_security_network_rp_filter:-1}
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# ── ICMP (SEC-006: allow ping/PMTUD; ignore broadcast & bogus) ───────────────
net.ipv4.icmp_echo_ignore_all = \${CONF_kernel_security_network_icmp_echo_ignore_all:-0}
net.ipv4.icmp_echo_ignore_broadcasts = \${CONF_kernel_security_network_icmp_echo_ignore_broadcasts:-1}
net.ipv4.icmp_ignore_bogus_error_responses = 1

# ── TCP security (SEC-005: RFC 1337 TIME-WAIT + SYN cookies) ─────────────────
net.ipv4.tcp_syncookies = \${CONF_kernel_security_network_tcp_syncookies:-1}
net.ipv4.tcp_rfc1337 = 1

# ── Kernel memory & system (SEC-005) ─────────────────────────────────────────
kernel.dmesg_restrict = \${CONF_kernel_security_security_dmesg_restrict:-1}
kernel.kptr_restrict = \${CONF_kernel_security_security_kptr_restrict:-2}
kernel.randomize_va_space = \${CONF_kernel_security_security_randomize_va_space:-2}
kernel.yama.ptrace_scope = 1

# ── Filesystem link & core dump protection (SEC-005) ─────────────────────────
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.protected_fifos = 2
fs.protected_regular = 2
fs.suid_dumpable = 0
EOF

        if [ "$DISABLE_IPV6" = "y" ]; then
            echo "net.ipv6.conf.all.disable_ipv6 = 1"     >> "$sysctl_tmp"
            echo "net.ipv6.conf.default.disable_ipv6 = 1" >> "$sysctl_tmp"
        fi

        sudo cp "$sysctl_tmp" /etc/sysctl.d/99-security.conf
        sudo chmod 644 /etc/sysctl.d/99-security.conf
        rm -f "$sysctl_tmp"

        sudo sysctl -p /etc/sysctl.d/99-security.conf > /dev/null 2>&1 || true

        print_success "Kernel security hardening applied"
    fi
}
