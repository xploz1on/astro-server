# 🐧 Linux Reviewer: Distribution & System Architecture Audit

**Date:** 2026-09-04  
**Reviewer:** Linux Code Reviewer Agent  
**Scope:** Distribution portability, package management, service managers, FHS paths  
**Status:** COMPLETE  

---

## Distribution Compatibility Matrix

| Component | Ubuntu 22/24 | Debian 11/12 | RHEL 8/9 / Rocky / Alma | Fedora 39+ | Arch Linux |
|-----------|--------------|--------------|-------------------------|------------|------------|
| Package Updates | 🟢 PASS (apt) | 🟢 PASS (apt) | 🔴 FAIL (no dnf) | 🔴 FAIL (no dnf) | 🔴 FAIL (no pacman) |
| Auto Updates | 🟢 PASS (unattended-upgrades) | 🟢 PASS | 🔴 FAIL (needs dnf-automatic) | 🔴 FAIL | 🔴 FAIL |
| Package Check (`dpkg -l`) | 🟢 PASS | 🟢 PASS | 🔴 FAIL (needs `rpm -q`) | 🔴 FAIL | 🔴 FAIL (needs `pacman -Q`) |
| Firewall (UFW) | 🟢 PASS | 🟢 PASS | 🟡 WARN (firewalld default) | 🟡 WARN (firewalld) | 🟡 WARN (iptables/nftables) |
| SSH Service Name | 🟢 PASS (`ssh`) | 🟢 PASS (`ssh`) | 🔴 FAIL (named `sshd`) | 🔴 FAIL (named `sshd`) | 🔴 FAIL (named `sshd`) |
| Fail2Ban Config | 🟢 PASS | 🟢 PASS | 🟢 PASS | 🟢 PASS | 🟢 PASS |
| Sysctl Paths | 🟢 PASS | 🟢 PASS | 🟢 PASS | 🟢 PASS | 🟢 PASS |

---

## Critical Compatibility Issues

### [LINUX-001] Hardcoded `apt-get` & `apt` Commands in Core Script
- **File:** `scripts/Astro-server.sh` Lines: 122, 137, 246, 501, 725
- **Description:** The script directly invokes `apt update` and `apt-get install -y fail2ban ufw unattended-upgrades`. On RHEL, CentOS, Rocky, Alma, Fedora, openSUSE, or Arch, the script crashes immediately.
- **Affected:** RHEL, Rocky Linux, AlmaLinux, Fedora, Arch Linux, Alpine.
- **Fix:** Implement an abstraction layer `pkg_install()` and `pkg_update()` that inspects `/etc/os-release` (ID, ID_LIKE) and routes to `apt`, `dnf`, or `pacman`.

### [LINUX-002] Debian-Specific `unattended-upgrades` Package & Configuration
- **File:** `scripts/Astro-server.sh` Lines: 700-750
- **Description:** Automatic updates are implemented by writing to `/etc/apt/apt.conf.d/50unattended-upgrades` and `/etc/apt/apt.conf.d/20auto-upgrades`.
- **Affected:** All non-Debian distributions.
- **Fix:** For RHEL/Rocky/Alma/Fedora, install and configure `dnf-automatic` (`systemctl enable --now dnf-automatic.timer`). For Arch, suggest systemd timers or pacman hooks.

### [LINUX-003] Debian-Only Package Verification via `dpkg -l`
- **File:** `scripts/Astro-server.sh` Line: 721, `astro` Line: 382
- **Description:** Package existence checks use `dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"`.
- **Affected:** RHEL, Fedora, Rocky, Alma, Arch.
- **Fix:** Use distro-agnostic command check: `command -v "$binary"` or helper `is_pkg_installed "$pkg"`.

### [LINUX-004] Hardcoded SSH Service Name (`ssh` vs `sshd`)
- **File:** `scripts/Astro-server.sh` Line: 360, `scripts/security-report.sh` Line: 53
- **Description:** The script calls `systemctl restart ssh` or `journalctl -u ssh.service`. On Red Hat family distributions (RHEL, Fedora, Rocky, CentOS), the systemd service name is `sshd.service`, causing service restart failure and report generation errors.
- **Fix:** Define `SSH_SERVICE="ssh"` on Debian/Ubuntu and `SSH_SERVICE="sshd"` on RHEL/Fedora/Arch.

---

## Path & Permission Issues

### [PATH-001] Direct Mutation of `/etc/ssh/sshd_config`
- **Description:** Rather than taking advantage of `/etc/ssh/sshd_config.d/*.conf` (available in modern OpenSSH 8.2+ across Ubuntu 20.04+, Debian 11+, RHEL 9), the script modifies the monolith file directly.
- **Recommendation:** Use drop-in configuration file `/etc/ssh/sshd_config.d/99-astro-hardening.conf` where supported, leaving the distribution-provided `sshd_config` intact.

---

## Positive Observations
- Sysctl configurations use `/etc/sysctl.d/99-security.conf` following modern FHS/systemd conventions.
- Proper handling of UFW port configurations.
- Clear separation of Ansible automation templates.
