# 🔒 Security Reviewer: Initial Codebase Security Audit

**Date:** 2026-09-04  
**Reviewer:** Security Reviewer Agent  
**Scope:** `scripts/Astro-server.sh`, `scripts/security-report.sh`, `ansible/templates/*`, sysctl configs  
**Status:** COMPLETE — CRITICAL VULNERABILITY IDENTIFIED  

---

## Risk Summary

| Severity | Count | Status |
|----------|-------|--------|
| **Critical** | 1 | Unresolved — Requires Immediate Fix |
| **High** | 2 | Action Required |
| **Medium** | 4 | Action Required |
| **Low** | 2 | Scheduled |

---

## Critical Findings

### [CRIT-001 / SEC-001] Private SSH Key Dumped in Plaintext to Terminal
- **File:** `scripts/Astro-server.sh` Line: 311
- **Code:** `echo -e "${WHITE}$(cat ~/.ssh/id_ed25519)${NC}"`
- **Description:** During the SSH key generation wizard, if an ED25519 keypair is generated on the server, the private key is printed directly into the standard output stream.
- **Impact:** Any terminal logger, screen sharing session, session recording (script, asciinema), bastion log, or terminal scrollback buffer captures the raw private SSH key in cleartext. This completely compromises the server identity and administrative credentials. Generating the private key on the remote server rather than client-side is an anti-pattern.
- **Remediation:** 
  1. Never print private key contents to standard out.
  2. Advise the user to generate keys locally on their workstation (`ssh-keygen -t ed25519`) and upload with `ssh-copy-id`.
  3. If generating on the server in emergency headless mode, instruct secure retrieval or save to a restricted, temporary download token, never `cat` to terminal.
- **Reference:** CIS Benchmark 5.2 (SSH Server Configuration), OWASP Secure Coding Practices (Cryptographic Practices).

---

## High Findings

### [SEC-002] Unverified External IP Fetch for Administrative Firewall Whitelisting
- **File:** `scripts/Astro-server.sh` Line: 423
- **Code:** `curl -s https://api.ipify.org` without TLS pinning, DNS validation, or CIDR sanitization.
- **Description:** The script queries an unauthenticated external 3rd-party web service over HTTP/HTTPS to detect the admin's IP and directly whitelists it in UFW.
- **Impact:** If the external service is spoofed, intercepted via DNS hijack, or returns an unexpected response / malicious payload, firewall rules can be corrupted or allow arbitrary access.
- **Remediation:** Validate that the returned string matches a strict IPv4/IPv6 regex before passing to `ufw allow from <IP>`.

### [SEC-003] Indefinite Accumulation of SSH Config Backups in `/etc/ssh/`
- **File:** `scripts/Astro-server.sh` Line: 330
- **Description:** Every run copies `sshd_config` to `/etc/ssh/sshd_config.backup.$(date +%Y%m%d_%H%M%S)`.
- **Impact:** Backup files left in `/etc/ssh/` retain old and potentially vulnerable configurations, clutter administrative directories, and may be read if file permissions are not explicitly locked down to `0600`.
- **Remediation:** Store backups in a dedicated directory (e.g. `/var/backups/astro-server/`) with `0600` permissions and prune backups older than 30 days.

---

## Medium Findings

### [SEC-004] Missing Modern HostKeyAlgorithms in SSH Templates
- **File:** `ansible/templates/sshd_config.j2`
- **Description:** Template specifies `KexAlgorithms`, `Ciphers`, and `MACs`, but lacks explicit modern `HostKeyAlgorithms` restricting host keys to `ssh-ed25519,rsa-sha2-512,rsa-sha2-256`.
- **Remediation:** Explicitly declare `HostKeyAlgorithms ssh-ed25519,rsa-sha2-512,rsa-sha2-256`.

### [SEC-005] Missing Essential Kernel Hardening Sysctl Directives
- **File:** `ansible/templates/99-security.conf.j2` and `scripts/Astro-server.sh` Line: 580-630
- **Description:** The sysctl configuration lacks:
  - `net.ipv4.tcp_rfc1337 = 1` (Protects against TCP TIME-WAIT assassination attacks)
  - `fs.protected_fifos = 2` (Restricts FIFO writes in world-writable directories)
  - `fs.protected_regular = 2` (Restricts regular file writes in world-writable directories)
  - `kernel.yama.ptrace_scope = 1` (Restricts ptrace scope)
- **Remediation:** Add these parameters into both the Ansible template and the bash script.

### [SEC-006] ICMP Echo Ignore All Disrupts Legitimate Monitoring
- **File:** `scripts/Astro-server.sh` Line: 598 (`net.ipv4.icmp_echo_ignore_all = 1`)
- **Description:** Completely dropping all ICMP packets breaks path MTU discovery (PMTUD), network diagnostics (ping), and uptime monitors.
- **Remediation:** Set `net.ipv4.icmp_echo_ignore_broadcasts = 1` and `net.ipv4.icmp_ignore_bogus_error_responses = 1`, but leave `icmp_echo_ignore_all = 0` (or make it optional via configuration profile).

---

## Compliance Status

| Standard | Control | Status | Notes |
|----------|---------|--------|-------|
| CIS Ubuntu 22.04 | 5.2.1 (SSH Permissions) | PASS | Configs set to 600 |
| CIS Ubuntu 22.04 | 5.2.14 (SSH PermitRootLogin) | PASS | Set to no |
| CIS Ubuntu 22.04 | 5.2.20 (SSH MaxAuthTries) | PASS | Set to 3 |
| CIS Linux | 3.2.1 (Sysctl IP Forwarding) | PASS | Disabled |
| CIS Linux | 4.1 (Auditd Logging) | GAP | auditd not yet managed |
| CIS Linux | 1.4 (Filesystem Integrity) | GAP | AIDE/Tripwire not yet managed |

---

## Positive Security Controls
- Strong SSH cipher list (`chacha20-poly1305@openssh.com,aes256-gcm@openssh.com`).
- Password authentication disabled by default (`PasswordAuthentication no`).
- Automatic Fail2Ban integration configured for SSH protection.
- Core network protections (SYN cookies, reverse path filtering, martian packet logging).

---

## Escalation Notice to Overseer
> **ALERT:** [CRIT-001] must be patched prior to tag v1.0.1 or public distribution.
