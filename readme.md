# 🚀 Astro Server Security Toolkit

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Shell](https://img.shields.io/badge/Shell-Bash%20(set%20--euo%20pipefail)-green.svg)](https://www.gnu.org/software/bash/)
[![Ansible](https://img.shields.io/badge/Ansible-Ready-red.svg)](https://www.ansible.com/)
[![Security](https://img.shields.io/badge/Security-Hardened%20(CIS%2FNIST)-blue.svg)](https://github.com/xploz1on/astro-server)
[![AI Agents](https://img.shields.io/badge/AI%20Agents-5%20Specialists-purple.svg)](.agents/)

> **Enterprise-grade Linux server security hardening, monitoring, and multi-agent compliance toolkit**

Transform your Linux servers into impenetrable fortresses with automated security hardening, real-time intrusion monitoring, multi-server Ansible orchestration, and an integrated multi-agent review system.

---

## 🚀 Quick Start

### 📦 Install & Run (30 seconds)

```bash
# Option 1: Global Installation (Recommended)
curl -sSL https://raw.githubusercontent.com/xploz1on/astro-server/main/install.sh | sudo bash

# Run the interactive launcher 🎉
astro

# Option 2: Local Git Clone
git clone https://github.com/xploz1on/astro-server.git
cd astro-server
./astro
```

> [!TIP]
> **Zero configuration needed**: Astro Server launches an intuitive, interactive CLI menu. No complex flags or syntax to memorize.

---

### 🎨 Interactive Menu Preview

```text
    ╔═══════════════════════════════════════════════════════════════╗
    ║                    🛡️  ASTRO SERVER MENU                     ║
    ╚═══════════════════════════════════════════════════════════════╝

Available Operations:
  1) 🛡️  Harden Server          - Interactive security hardening wizard
  2) 📊 Generate Report         - Markdown security audit report
  3) 🚀 Deploy to Multiple      - Multi-server deployment via Ansible
  4) 🔍 System Check            - Distribution & compatibility verification
  5) 🔄 Update Toolkit          - Update Astro Server toolkit
  6) ℹ️  Version Info            - Show version details
  7) ❓ Help                     - Show detailed usage help
  0) 🚪 Exit                     - Exit Astro Server

Quick Profiles:
  dev) 💻 Development           - Remote SSH / VS Code compatible
  prod) 🔴 Production          - Maximum security hardening
  bal) 🟡 Balanced             - Balanced security with dev prompt (default)
  web) 🌐 Web Server           - Web server profile (HTTP/HTTPS enabled)
  db) 🗄️  Database             - Database server profile (locked down)
  a) ⚡ Aggressive              - High-security policy
  p) 🔒 Paranoid                - Maximum isolation & strict restrictions

Enter your choice:
```

---

### 💻 CLI & Non-Interactive Commands

```bash
# Apply security profiles directly
./astro harden --profile development # Remote dev / VS Code compatible
./astro harden --profile production  # Strict production hardening
./astro harden --profile balanced    # Balanced policy with interactive prompts
./astro harden --profile webserver   # Optimized for web workloads (80/443 open)
./astro harden --profile database    # Database server hardening

# Generate a security audit report (Markdown)
./astro report

# Run system compatibility check
./astro check

# Multi-server Ansible deployment
./astro deploy --inventory ansible/inventory/hosts
```

---

## 🤖 AI Agent Governance & Review System

Astro Server includes a dedicated multi-agent engineering framework located in [`.agents/`](.agents/). Each specialist agent maintains rigorous code quality, security posture, distribution compatibility, and architectural planning:

```
.agents/
├── README.md                      # Framework documentation & workflows
├── overseer/                      # 👁️ Command center, triage, STATUS.md
├── bash-code-reviewer/            # 🐚 ShellCheck, POSIX standards, Bash safety
├── security-reviewer/             # 🔒 CIS/NIST checks, crypto, audit reports
├── linux-code-reviewer/           # 🐧 Multi-distro compatibility, systemd, FHS
└── improvement-planner/           # 📈 Roadmap planning, architecture metrics
```

| Agent | Role | Scope | Audit Report |
|-------|------|-------|--------------|
| 👁️ **Overseer** | Command Center & Coordinator | Synthesizes findings, enforces quality gates | [STATUS.md](.agents/overseer/STATUS.md) |
| 🐚 **Bash Reviewer** | Shell Safety Specialist | `set -euo pipefail`, safe tempfiles, error traps | [REPORT.md](.agents/bash-code-reviewer/REPORT.md) |
| 🔒 **Security Reviewer** | Cryptographic & System Security | Zero-leak keys, modern ciphers, sysctl | [REPORT.md](.agents/security-reviewer/REPORT.md) |
| 🐧 **Linux Reviewer** | OS Portability Specialist | Multi-distro package managers, systemd units | [REPORT.md](.agents/linux-code-reviewer/REPORT.md) |
| 📈 **Improvement Planner** | Architecture & Roadmap | Modularization, automated testing, metrics | [REPORT.md](.agents/improvement-planner/REPORT.md) |

> [!NOTE]
> Check current project health and open tasks at any time in [`.agents/overseer/STATUS.md`](.agents/overseer/STATUS.md).

---

## 🛡️ Enterprise Security Controls

### 🔐 Modern SSH Hardening
- **Zero Cleartext Leakage**: Private keys are **never** dumped to standard output. Users are guided to paste public keys or retrieve keys securely via SCP/SFTP with `0600` permissions.
- **Modern Cryptography**: Enforces `ssh-ed25519,rsa-sha2-512,rsa-sha2-256` for `HostKeyAlgorithms` and Curve25519 key exchange algorithms.
- **Root & Password Restrictions**: Disables root login (`PermitRootLogin no`) and enforces key-based authentication (`PasswordAuthentication no`).
- **Connection Rate Limiting**: `MaxAuthTries 3`, `MaxSessions 2`, and aggressive brute-force drop policies.
- **Isolated Backups**: Pre-change configurations are archived into `/var/backups/astro-server/` with mode `0700`/`0600` and automatic 30-day retention pruning.

### 🚨 Intrusion Prevention (Fail2Ban)
- **Aggressive Mode**: Protects SSH and system services with configurable ban durations (1 hour to 1 week).
- **IP Validation & Sanitization**: External IP lookup queries are strictly validated against IPv4/IPv6 patterns before appending to `ignoreip`.
- **Dynamic Service Tracking**: Interacts seamlessly with distribution-specific service names (`ssh` on Debian/Ubuntu, `sshd` on RHEL/Fedora/Arch).

### 🔥 Firewall Orchestration (UFW & firewalld)
- **Default Deny**: Denies all unsolicited inbound traffic; rate-limits SSH.
- **Lockout Prevention**: Guaranteed preservation and verification of port 22 access before activating firewall rules.
- **Service Profiles**: Dedicated rule presets for web, database, and custom port configurations.

### 🔧 Kernel & Network Hardening (`sysctl`)
- **RFC 1337 Protection**: `net.ipv4.tcp_rfc1337 = 1` protects against TCP TIME-WAIT assassination attacks.
- **Filesystem Link Restrictions**: `fs.protected_hardlinks = 1`, `fs.protected_symlinks = 1`, `fs.protected_fifos = 2`, and `fs.protected_regular = 2`.
- **Memory & Process Security**: `kernel.randomize_va_space = 2` (full ASLR), `kernel.dmesg_restrict = 1`, `kernel.kptr_restrict = 2`, `kernel.yama.ptrace_scope = 1`, and core dumps disabled (`fs.suid_dumpable = 0`).
- **Network Integrity**: Reverse path filtering (`rp_filter = 1`), martian packet logging (`log_martians = 1`), SYN flood defense (`tcp_syncookies = 1`), source routing disabled, and PMTUD-friendly ICMP configuration.

### 🔄 Distro-Aware Automatic Updates
- **Debian / Ubuntu**: Automated security updates managed via `unattended-upgrades`.
- **RHEL / Rocky / Alma / Fedora**: Automated security updates managed via `dnf-automatic.timer`.

---

## 🐧 Supported Distributions

Astro Server features a built-in OS abstraction layer supporting major enterprise Linux distributions:

| Distribution Family | Supported Versions | Package Manager | SSH Service | Firewall |
|---------------------|--------------------|-----------------|-------------|----------|
| **Ubuntu** | 20.04 LTS, 22.04 LTS, 24.04 LTS | `apt` | `ssh` | UFW |
| **Debian** | 11 (Bullseye), 12 (Bookworm) | `apt` | `ssh` | UFW |
| **RHEL / Rocky / Alma** | 8.x, 9.x | `dnf` | `sshd` | UFW / firewalld |
| **Fedora** | 38, 39, 40+ | `dnf` | `sshd` | UFW / firewalld |
| **Arch Linux** | Current rolling | `pacman` | `sshd` | UFW / iptables |
| **Derivatives** | Pop!_OS, Mint, Kali, AlmaLinux | `apt` / `dnf` | Dynamic | UFW |

---

## 📁 Repository Structure

```text
astro-server/
├── astro                     # 🎯 Main unified CLI launcher script
├── config/                   # ⚙️ Configuration
│   └── astro.yml             # Single-Source-of-Truth YAML baseline for Bash & Ansible
├── scripts/                  # 🔧 Core execution scripts
│   ├── Astro-server.sh       # Standalone interactive thin orchestrator
│   ├── security-report.sh    # Markdown security audit report generator
│   └── lib/                  # Modular library functions (colors, ssh, sysctl, etc.)
├── ansible/                  # 🤖 Multi-server automation
│   ├── playbooks/            # Deployment playbooks (harden-servers.yml)
│   ├── inventory/            # Host inventories (hosts, hosts.example)
│   ├── group_vars/           # (Symlinked to config/astro.yml)
│   ├── tasks/                # Reusable task definitions
│   └── templates/            # Hardened configuration templates (sshd, fail2ban, sysctl)
├── tests/                    # 🧪 Automated Testing
│   ├── run_tests.sh          # Native test assertions & runner
│   ├── unit/                 # Bats-core unit test suite
│   └── integration/          # Vagrant multi-distribution real VM matrix
├── .agents/                  # 🤖 AI Agent review & governance framework
│   ├── README.md             # Agent overview and usage guide
│   ├── overseer/             # Overseer agent & STATUS.md
│   ├── bash-code-reviewer/   # Bash review agent & audit reports
│   ├── security-reviewer/    # Security review agent & audit reports
│   ├── linux-code-reviewer/  # Linux compatibility review agent
│   └── improvement-planner/  # Improvement planner agent
├── docs/                     # 📚 Documentation

│   ├── INSTALL.md            # Installation instructions
│   ├── PROFILES.md           # Security profiles specification
│   ├── STANDALONE-USAGE.md   # Single-server guide
│   └── ANSIBLE-USAGE.md      # Multi-server deployment guide
├── LICENSE                   # Apache 2.0 License
├── CONTRIBUTING.md           # Contribution guidelines
├── SECURITY.md               # Vulnerability reporting protocol
├── CHANGELOG.md              # Version release history
└── ROADMAP.md                # Strategic development milestones
```

---

## 🤖 Multi-Server Orchestration (Ansible)

```bash
# 1. Install Ansible using your distribution package manager
sudo apt install ansible    # Debian / Ubuntu
sudo dnf install ansible    # RHEL / Rocky / Fedora
sudo pacman -S ansible      # Arch Linux

# 2. Configure inventory
cp ansible/inventory/hosts.example ansible/inventory/hosts
vim ansible/inventory/hosts

# 3. Dry-run deployment check
./astro deploy --check

# 4. Deploy hardening across fleet
./astro deploy --inventory ansible/inventory/hosts

# 5. Limit deployment to specific group
./astro deploy --limit webservers
```

---

## 📊 Sample Security Audit Report

Generate a Markdown report anytime by running `./astro report`:

```markdown
# 🛡️ Server Security Status Report

> **Generated:** 2026-09-04 10:45:00 UTC  
> **Hostname:** `server-01.astro.internal`  
> **System:** Ubuntu 22.04.4 LTS (Jammy Jellyfish)

## 📊 Executive Summary

| Metric | Status | Value |
|--------|--------|-------|
| **Security Level** | 🟢 **SECURE** | Active monitoring |
| **Fail2Ban Protection** | 🟢 | running |
| **Failed Login Attempts (24h)** | ✅ | 0 attempts |
| **Currently Banned IPs** | ✅ | 0 IPs blocked |
| **System Uptime** | 🕐 | up 14 days, 3 hours |

## 🔒 Security Services Status
- 🟢 **SSH**: Root login disabled, key authentication only, modern ciphers
- 🟢 **Fail2Ban**: Jails active (`sshd`), aggressive protection enabled
- 🟢 **Firewall**: UFW active, minimal attack surface, SSH rate-limited
- 🟢 **Kernel**: RFC 1337, ASLR, protected FIFOs/symlinks enabled
```

---

## 🎯 Development Roadmap

- [x] **v1.0.0**: Core Interactive Hardening, Markdown Reporting, Ansible Automation.
- [x] **v1.0.1**: Security & Portability Patch (Zero-leak SSH keys, RFC 1337 sysctl, distro package abstraction, safe shell flags).
- [x] **v1.1.0**: Modular Architecture (`scripts/lib/`), Bats-core + Vagrant CI testing, Single-Source-of-Truth YAML Config.
- [ ] **v1.2.0**: Rollback mechanics and CIS Linux Benchmark Level 1 automated scoring & auditing.
- [ ] **v1.3.0**: Container runtime hardening (Docker & Podman security profiles) and zero-dependency binary distribution.

---

## 🤝 Contributing

Contributions are welcome! Please consult [CONTRIBUTING.md](CONTRIBUTING.md) for details on code style, ShellCheck requirements, and testing workflows.

```bash
# 1. Fork & clone repository
git clone https://github.com/xploz1on/astro-server.git
cd astro-server

# 2. Create feature branch
git checkout -b feature/awesome-hardening

# 3. Validate syntax before submitting
bash -n astro scripts/*.sh

# 4. Commit and open Pull Request
git commit -m "feat: add CIS Benchmark 1.2 check"
git push origin feature/awesome-hardening
```

---

## 📄 License & Security

- **License**: Licensed under the [Apache License 2.0](LICENSE).
- **Security Policy**: For responsible disclosure of security issues, please refer to [SECURITY.md](SECURITY.md) or contact `dp@astro-tech.cloud`.
