# 🚀 Astro Server Security Toolkit

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Ansible](https://img.shields.io/badge/Ansible-Ready-red.svg)](https://www.ansible.com/)
[![Security](https://img.shields.io/badge/Security-Hardening-blue.svg)](https://github.com/xploz1on/astro-tech)

> **Enterprise-grade server security hardening and monitoring toolkit**

Transform your Linux servers into impenetrable fortresses with automated security hardening, real-time monitoring, and multi-server deployment capabilities.

## 🚀 Quick Start

### 📦 Install & Run (30 seconds)

```bash
# 1. Download and setup
git clone https://github.com/xploz1on/astro-server.git
cd astro-tech
chmod +x astro

# 2. Run it! 🎉
./astro
```

**That's it!** Astro Server will show you a beautiful interactive menu. No need to remember commands or profiles!

### 🎨 Interactive Menu Preview

```
    ╔═══════════════════════════════════════════════════════════════╗
    ║                    🛡️  ASTRO SERVER MENU                    ║
    ╚═══════════════════════════════════════════════════════════════╝

Available Operations:
  1) 🛡️  Harden Server          - Interactive security hardening
  2) 📊 Generate Report         - Security status report
  3) 🚀 Deploy to Multiple      - Deploy via Ansible
  4) 🔍 System Check            - Compatibility verification
  5) 🔄 Update Toolkit          - Update Astro Server
  6) ℹ️  Version Info            - Show version details
  7) ❓ Help                     - Show detailed help
  0) 🚪 Exit                     - Exit Astro Server

Quick Profiles:
  w) 🌐 Web Server              - Optimized for web servers
  d) 🗄️  Database Server        - Optimized for databases
  a) ⚡ Aggressive              - High security settings
  p) 🔒 Paranoid                - Maximum security

Enter your choice:
```

**Just type a number or letter and press Enter!** 🎉

### 🚀 Advanced Usage (Command Line)

```bash
# Quick hardening with specific profiles
./astro harden --profile web         # Web server optimized
./astro harden --profile database    # Database server optimized
./astro harden --profile aggressive  # High security
./astro harden --profile paranoid    # Maximum security

# Generate security report
./astro report

# System compatibility check
./astro check

# Multi-server deployment
./astro deploy --inventory hosts
```

## 📋 Table of Contents

- [✨ Why Astro Server?](#-why-astro-server)
- [🌟 Features](#-features)
- [🛡️ Security Features](#️-security-features)
- [🐧 Supported Distributions](#-supported-distributions)
- [📚 Documentation & Advanced Usage](#-documentation--advanced-usage)
- [🎯 Roadmap](#-roadmap)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)
- [🆘 Support & Community](#-support--community)

## ✨ Why Astro Server?

- 🎯 **One Command Launch** - Just run `./astro` and you're ready to go!
- 🛡️ **Enterprise-Grade Protection** - Multi-layer security used by Fortune 500 companies
- 📊 **Beautiful Reporting** - Professional security reports that executives love
- 🤖 **Automation Ready** - Scale from 1 to 1000+ servers with Ansible
- 🐧 **Universal Compatibility** - Works across all major Linux distributions
- 🔒 **Zero Trust Approach** - Assume breach, verify everything
- 📈 **Continuous Monitoring** - Real-time threat detection and response
- 🎨 **Beautiful Interface** - No more remembering complex commands or profiles

## 🌟 Features

- 🎯 **One-Command Launch** - Just run `./astro` for beautiful interactive menu
- 🎨 **Interactive Security Hardening** - Beautiful, colorful CLI interface with guided setup
- 🛡️ **Multi-Layer Protection** - SSH, Fail2Ban, Firewall, Kernel hardening in one tool
- 📊 **Professional Security Reports** - Markdown reports with executive summaries and metrics
- 🔄 **Ansible Automation** - Deploy across multiple servers with infrastructure as code
- 🐧 **Multi-Distro Support** - Ubuntu, Debian, Fedora, RHEL, Arch Linux support
- 📱 **Real-time Monitoring** - Continuous security status tracking and alerting
- 🎯 **Zero-Config Setup** - Smart defaults with expert recommendations
- 🔧 **Customizable Profiles** - Pre-built configurations for different server types
- 🚀 **Quick Profile Access** - Instant access to web, database, aggressive, and paranoid profiles

## 🛡️ Security Features

### 🔐 SSH Hardening
- ❌ Disable root login
- 🔑 Key-based authentication enforcement
- 🚫 Connection attempt limits
- ⏱️ Session timeouts
- 🔒 Protocol restrictions

### 🛡️ Intrusion Prevention
- 🚨 Fail2Ban with aggressive mode
- 🕐 Configurable ban durations (1h - 1 week)
- 🌐 Real-time IP blocking
- 📊 Attack pattern analysis

### 🔥 Network Security
- 🛡️ UFW firewall configuration
- 🚪 Smart port management
- 🔒 Default deny policies
- 🌐 Custom service rules

### 🔧 Kernel Hardening
- 🚫 IP forwarding disabled
- 🔒 ICMP protections
- 🛡️ Source routing disabled
- 🎯 Enhanced ASLR

### 📊 Monitoring & Reporting
- 📈 Real-time security dashboards
- 📋 Markdown status reports
- 🚨 Attack trend analysis
- 📊 Resource monitoring

## 🐧 Supported Distributions

### ✅ Fully Supported
- **Ubuntu** 18.04+ (LTS recommended)
- **Debian** 10+ (Buster, Bullseye, Bookworm)
- **Linux Mint** (All versions)
- **Pop!_OS** (All versions)
- **Elementary OS** (All versions)

### ✅ Fedora/RHEL Family
- **Fedora** 35+
- **RHEL/CentOS** 8+
- **Rocky Linux** (All versions)
- **AlmaLinux** (All versions)
- **Oracle Linux** (All versions)

### 🔄 Experimental Support
- **Arch Linux** & derivatives (Manjaro, EndeavourOS)
- **Alpine Linux**
- **openSUSE**

### ❌ Not Supported
- **macOS** - Linux systems only
- **Windows** - Use WSL for Windows support

## 📚 Documentation & Advanced Usage

### 📖 Installation Methods

```bash
# Method 1: Clone from GitHub (Recommended)
git clone https://github.com/xploz1on/astro-server.git
cd astro-tech
chmod +x astro

# Method 2: Download and extract
wget https://github.com/xploz1on/astro-tech/archive/main.zip
unzip main.zip && cd astro-tech-main
chmod +x astro

# Method 3: One-line installer (Coming Soon)
curl -sSL https://get.astro-tech.cloud | bash
```

### 🤖 Multi-Server Deployment with Ansible

```bash
# 🎯 EASIEST WAY: Use the interactive menu!
./astro
# Then select "Deploy to Multiple" from the menu

# 🚀 COMMAND LINE OPTIONS (for advanced users):
# 1. Install Ansible
sudo apt install ansible  # Ubuntu/Debian
sudo dnf install ansible  # Fedora/RHEL

# 2. Configure your server inventory
cp ansible/inventory/hosts.example ansible/inventory/hosts
vim ansible/inventory/hosts

# 3. Deploy to all servers
./astro deploy --inventory ansible/inventory/hosts

# 4. Deploy to specific server groups
./astro deploy --limit web-servers

# 5. Generate reports for all servers
./astro deploy --playbook security-reports.yml
```

### 📊 Example Security Report Output

```markdown
# 🛡️ Server Security Status Report

## 📊 Executive Summary
| Metric | Status | Value |
|--------|--------|-------|
| **Security Level** | 🟢 **SECURE** | Active monitoring |
| **Failed Login Attempts (24h)** | ✅ | 0 attempts |
| **Currently Banned IPs** | ✅ | 0 IPs blocked |

## 🔒 Security Services Status
✅ SSH hardened with key-only authentication
✅ Fail2Ban active with aggressive monitoring  
✅ Firewall configured with minimal attack surface
✅ Kernel hardened against network attacks
```

### 🔧 Configuration

#### SSH Security Templates
```bash
astro-server/configs/ssh/
├── hardened-sshd.conf      # Production SSH config
├── paranoid-sshd.conf      # Maximum security
└── development-sshd.conf   # Dev-friendly config
```

#### Fail2Ban Profiles
```bash
astro-server/configs/fail2ban/
├── aggressive.conf         # High security
├── balanced.conf          # Recommended
└── permissive.conf        # Light protection
```

#### Firewall Rules
```bash
astro-server/configs/firewall/
├── web-server.rules       # HTTP/HTTPS services
├── database.rules         # Database servers
└── minimal.rules          # SSH-only access
```

### 📁 Project Structure

```
astro-server/
├── astro                     # 🎯 Main launcher script
├── scripts/                  # 🔧 Core security scripts
│   ├── Astro-server.sh          # Interactive hardening wizard
│   ├── security-report.sh       # Markdown report generator  
├── ansible/                  # 🤖 Multi-server automation
│   ├── playbooks/               # Deployment playbooks
│   ├── inventory/               # Server inventories
│   ├── group_vars/              # Configuration variables
│   └── roles/                   # Reusable Ansible roles
├── configs/                  # ⚙️ Security templates
│   ├── ssh/                     # SSH hardening configs
│   ├── fail2ban/                # Intrusion prevention rules
│   └── firewall/                # Firewall rule templates
├── docs/                     # 📚 Comprehensive documentation
│   ├── INSTALL.md               # Installation guide
│   ├── STANDALONE-USAGE.md      # Single server usage
│   ├── ANSIBLE-USAGE.md         # Multi-server deployment
│   └── changelog.md             # Security audit history
├── .github/                  # 🔄 GitHub automation
│   ├── workflows/               # CI/CD pipelines
│   └── ISSUE_TEMPLATE/          # Issue templates
├── LICENSE                   # 📄 Apache 2.0 License
├── CONTRIBUTING.md           # 🤝 Contribution guidelines
└── README.md                 # 📖 This file
```

| Guide | Description | Audience |
|-------|-------------|----------|
| [🚀 Quick Start](#-quick-start) | Get started in 5 minutes | Everyone |
| [📖 Installation Guide](docs/INSTALL.md) | Detailed setup instructions | Administrators |
| [🖥️ Standalone Usage](docs/STANDALONE-USAGE.md) | Single server hardening | System Administrators |
| [🤖 Ansible Usage](docs/ANSIBLE-USAGE.md) | Multi-server deployment | DevOps Engineers |
| [🤝 Contributing](CONTRIBUTING.md) | How to contribute | Developers |
| [🗺️ Roadmap](ROADMAP.md) | Development roadmap | Everyone |

## 🎯 Roadmap

### ✅ Phase 1: Core Features (v1.0.0)
- [x] Interactive security hardening with beautiful CLI
- [x] Professional markdown security reports  
- [x] Multi-layer protection (SSH, Fail2Ban, Firewall, Kernel)
- [x] Configuration templates and profiles
- [x] Comprehensive documentation

### ✅ Phase 2: Ansible Automation (v1.1.0) - COMPLETE
- [x] Complete Ansible playbook framework
- [x] Multi-server deployment with templates and tasks
- [x] Multi-OS support (Debian/Ubuntu, RedHat/Fedora)
- [x] Environment management (dev/staging/prod)
- [x] Firewall automation (UFW/firewalld)
- [ ] Advanced role-based architecture
- [ ] Automated report collection

### 🐧 Phase 3: Multi-Distribution Support (v1.2.0)
- [ ] Fedora/RHEL/CentOS support
- [ ] Arch Linux support  
- [ ] Package manager abstraction
- [ ] Distribution-specific optimizations
- [ ] Automated compatibility testing

### 🔒 Phase 4: Advanced Security (v1.3.0)
- [ ] Container security (Docker/Kubernetes)
- [ ] Compliance frameworks (CIS, NIST, PCI DSS)
- [ ] SIEM integration (ELK, Splunk)
- [ ] Threat intelligence feeds
- [ ] Zero Trust architecture

### ☁️ Phase 5: Cloud & Enterprise (v2.0.0)
- [ ] AWS/Azure/GCP integration
- [ ] Web management dashboard
- [ ] RESTful API
- [ ] Mobile app support
- [ ] Commercial licensing

## 🤝 Contributing

We welcome contributions from security professionals, system administrators, and developers! 

### 🎯 Ways to Contribute

| Area | Skills Needed | Impact |
|------|---------------|--------|
| 🐧 **Multi-distro support** | Linux administration, package management | High |
| 🤖 **Ansible development** | Ansible, YAML, infrastructure as code | High |
| 🔒 **Security research** | Security hardening, compliance frameworks | Critical |
| 📊 **Monitoring integration** | Prometheus, Grafana, ELK Stack | Medium |
| 📝 **Documentation** | Technical writing, tutorials | High |
| 🧪 **Testing** | QA, automated testing, CI/CD | Medium |

### 🚀 Quick Contribution Guide

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Test** your changes thoroughly
4. **Commit** with clear messages (`git commit -m 'Add amazing feature'`)
5. **Push** to your branch (`git push origin feature/amazing-feature`)
6. **Open** a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🆘 Support & Community

### 📞 Getting Help
- 📖 **Documentation**: Comprehensive guides in [`docs/`](docs/)
- 🐛 **Bug Reports**: [Create an issue](https://github.com/xploz1on/astro-tech/issues/new?template=bug_report.md)
- 💡 **Feature Requests**: [Suggest features](https://github.com/xploz1on/astro-tech/issues/new?template=feature_request.md)
- 💬 **Discussions**: [Community discussions](https://github.com/xploz1on/astro-tech/discussions)

### 🔒 Security
- **Security Issues**: Email dp@astro-tech.cloud (do not use public issues)
- **Security Advisories**: Check [GitHub Security Advisories](https://github.com/xploz1on/astro-tech/security/advisories)

### 🌟 Community
- **Contributors**: See [GitHub Contributors](https://github.com/xploz1on/astro-tech/graphs/contributors)
- **Code of Conduct**: We follow the [Contributor Covenant](https://www.contributor-covenant.org/)
- **Discussions**: Join our [community discussions](https://github.com/xploz1on/astro-tech/discussions)

## 🏆 Security Achievements

After running Astro Server, your infrastructure will achieve:

- 🛡️ **Enterprise-grade security posture**
- 📊 **Continuous threat monitoring**
- 🚨 **Automated attack prevention**
- 📋 **Compliance-ready reporting**
- 🔄 **Scalable security management**

---

**Transform your servers into ASTRO-level secure fortresses!** 🚀🛡️

*Built with ❤️ for the security community*
