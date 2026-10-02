#!/usr/bin/env bash
# lib/scoring.sh — Security score calculator
# Sourced by the main orchestrator; do NOT execute directly.
# Requires: lib/colors.sh sourced first.

# Quantifiable Security Score Calculator (0-100)
# Each check awards points for a verifiable hardening control.
calculate_security_score() {
    local score=0

    # 1. SSH Root login disabled (+15)
    if sudo grep -q "^PermitRootLogin no" /etc/ssh/sshd_config* 2>/dev/null; then
        score=$((score + 15))
    fi
    # 2. Password auth disabled (+15)
    if sudo grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config* 2>/dev/null; then
        score=$((score + 15))
    fi
    # 3. Fail2Ban active (+15)
    if command -v fail2ban-client &>/dev/null && sudo systemctl is-active --quiet fail2ban 2>/dev/null; then
        score=$((score + 15))
    fi
    # 4. Firewall active (+15) — UFW or firewalld
    if command -v ufw &>/dev/null && sudo ufw status 2>/dev/null | grep -q "Status: active"; then
        score=$((score + 15))
    elif command -v firewall-cmd &>/dev/null && sudo firewall-cmd --state 2>/dev/null | grep -q "running"; then
        score=$((score + 15))
    fi
    # 5. TCP RFC 1337 TIME-WAIT protection (+10)
    if sysctl net.ipv4.tcp_rfc1337 2>/dev/null | grep -q "= 1"; then
        score=$((score + 10))
    fi
    # 6. Full ASLR enabled (+10)
    if sysctl kernel.randomize_va_space 2>/dev/null | grep -q "= 2"; then
        score=$((score + 10))
    fi
    # 7. Protected symlinks + hardlinks (+10)
    if sysctl fs.protected_symlinks 2>/dev/null | grep -q "= 1"; then
        score=$((score + 10))
    fi
    # 8. SUID core dump restricted (+10)
    if sysctl fs.suid_dumpable 2>/dev/null | grep -q "= 0"; then
        score=$((score + 10))
    fi

    echo "$score"
}
