# 🖥️ Standalone Usage Guide

Complete guide for using Astro Server on individual servers without Ansible.

## 🎯 Overview

Standalone mode is perfect for:

- **Single server deployments**
- **Development environments**
- **Learning and testing**
- **Custom configurations**
- **Manual security audits**

## 🚀 Getting Started

### Prerequisites Check

```bash
# Run system compatibility check
./astro check

# Expected output:
# ✅ OS: Ubuntu 22.04 LTS
# ✅ Supported distribution
# ✅ Architecture: x86_64
# ✅ All dependencies available
# ✅ Sudo access confirmed
# ✅ Sufficient disk space
```

### Basic Usage

```bash
# Interactive hardening (recommended for beginners)
./astro harden

# Quick hardening with default profile
./astro harden --profile balanced

# Generate security report
./astro report
```

## 🛡️ Security Profiles

### Available Profiles

| Profile | Use Case | Security Level | Usability Impact |
|---------|----------|----------------|------------------|
| `minimal` | Development, Testing | 🟡 Basic | None |
| `balanced` | Production (Recommended) | 🟢 High | Minimal |
| `aggressive` | High-Security Environments | 🔴 Very High | Moderate |
| `paranoid` | Maximum Security | 🔴 Extreme | High |
| `web-server` | Web Applications | 🟢 High | Low |
| `database` | Database Servers | 🟢 High | Low |

### Profile Comparison

#### Minimal Profile

```bash
./astro harden --profile minimal
```

- SSH: Basic hardening only
- Fail2Ban: 30-minute bans, 5 attempts
- Firewall: Optional
- Kernel: No additional hardening

**Best for**: Development servers, testing environments

#### Balanced Profile (Default)

```bash
./astro harden --profile balanced
# or simply
./astro harden
```

- SSH: Root disabled, key-only auth, connection limits
- Fail2Ban: 1-hour bans, 3 attempts, aggressive mode
- Firewall: Recommended with smart defaults
- Kernel: Network security hardening

**Best for**: Most production servers

#### Aggressive Profile

```bash
./astro harden --profile aggressive
```

- SSH: Strict limits, short timeouts, no forwarding
- Fail2Ban: 24-hour bans, 2 attempts, recidive protection
- Firewall: Mandatory with strict rules
- Kernel: Full security hardening

**Best for**: Internet-facing servers, high-value targets

#### Paranoid Profile

```bash
./astro harden --profile paranoid
```

- SSH: Maximum restrictions, 1 attempt only
- Fail2Ban: 1-week bans, immediate blocking
- Firewall: Lockdown mode
- Kernel: All security features enabled

**Best for**: Critical infrastructure, compliance requirements

## 🔧 Advanced Usage

### Custom Configuration

```bash
# Use custom configuration file
./astro harden --config /path/to/custom.conf

# Example custom.conf:
# SECURITY_PROFILE="custom"
# SSH_MAX_AUTH_TRIES=2
# FAIL2BAN_BAN_TIME=7200
# ENABLE_FIREWALL=true
# FIREWALL_PROFILE="web-server"
```

### Step-by-Step Manual Configuration

#### 1. SSH Hardening Only

```bash
# Apply only SSH security settings
./astro harden --profile minimal

# Verify SSH configuration
sudo sshd -t
sudo systemctl reload ssh
```

#### 2. Fail2Ban Setup Only

```bash
# Install and configure Fail2Ban
./astro harden --profile balanced

# Check Fail2Ban status
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

#### 3. Firewall Configuration Only

```bash
# Configure UFW firewall
./astro harden --profile balanced

# Check firewall status
sudo ufw status verbose
```

#### 4. Kernel Hardening Only

```bash
# Apply kernel security settings
./astro harden --profile aggressive

# Verify kernel settings
sudo sysctl -a | grep -E "(net.ipv4|kernel)"
```

### Interactive Mode Walkthrough

When you run `./astro harden`, you'll be guided through:

#### Step 1: System Information

```
🖥️  Operating System: Ubuntu 22.04 LTS
🔧 Kernel Version:   5.15.0-56-generic
💻 Architecture:     x86_64
⏰ Uptime:          up 2 days, 4 hours

❓ Continue with security hardening? [Y/n]:
```

#### Step 2: Timezone Configuration

```
Current timezone: UTC

❓ Change timezone? [y/N]:
Available timezones:
1) UTC
2) America/New_York
3) Europe/London
4) Custom

Enter choice [1-4]:
```

#### Step 3: System Updates

```
📦 24 packages can be upgraded

❓ Upgrade all packages now? [Y/n]:
🔄 Upgrading packages (this may take a while)...
✅ System packages upgraded
```

#### Step 4: SSH Hardening

```
❓ Harden SSH configuration? [Y/n]:
🔐 Creating SSH configuration backup...
🔒 Disabling root login...
🛡️ Applying additional SSH security settings...
✅ SSH hardening applied successfully
```

#### Step 5: Fail2Ban Configuration

```
❓ Install and configure Fail2Ban? [Y/n]:
Choose ban duration for SSH attacks:
1) 1 hour (3600 seconds)
2) 6 hours (21600 seconds)
3) 24 hours (86400 seconds) - Recommended
4) 1 week (604800 seconds)

Enter choice [1-4]: 3
✅ Fail2Ban configured with 24 hour ban time
```

#### Step 6: Firewall Setup

```
❓ Configure UFW firewall? [y/N]:
⚠️  IMPORTANT: Make sure you have console access!

❓ Continue with firewall configuration? [y/N]:
❓ Allow HTTP (port 80)? [Y/n]:
❓ Allow HTTPS (port 443)? [Y/n]:
✅ UFW firewall configured and enabled
```

## 📊 Security Reporting

### Generate Reports

```bash
# Generate markdown security report
./astro report

# Output file: security-check.md
# View with: cat security-check.md
```

### Report Sections

The security report includes:

1. **Executive Summary** - High-level security status
2. **Security Services** - Fail2Ban, SSH, firewall status
3. **Network Security** - Open ports, firewall rules
4. **System Resources** - Memory, disk, load averages
5. **Attack Analysis** - Recent threats and patterns
6. **Recommendations** - Actionable security improvements

### Sample Report Output

```markdown
# 🛡️ Server Security Status Report

## 📊 Executive Summary
| Metric | Status | Value |
|--------|--------|-------|
| **Security Level** | 🟢 **SECURE** | Active monitoring |
| **Fail2Ban Protection** | 🟢 | active |
| **Failed Login Attempts (24h)** | ✅ | 0 attempts |

## 🔒 Security Services Status
✅ SSH: Root login disabled, key-only authentication
✅ Fail2Ban: Active with 0 banned IPs
✅ Firewall: UFW active with 3 rules
✅ Kernel: Security hardening applied

## 📋 Security Recommendations
✅ No critical security issues detected
Your server appears to be well-configured.
```

## 🔍 Monitoring and Maintenance

### Daily Security Checks

```bash
# Quick security status
./astro report

# Check for failed login attempts
sudo journalctl -u ssh.service --since "24 hours ago" | grep -i failed

# Review Fail2Ban activity
sudo fail2ban-client status sshd

# Check system updates
sudo apt list --upgradable
```

### Weekly Security Tasks

```bash
# Full security audit
./astro report > weekly-security-$(date +%Y%m%d).md

# Review firewall logs
sudo ufw show listening

# Check for security updates
sudo apt update && sudo apt list --upgradable | grep -i security

# Verify SSH configuration
sudo sshd -T | grep -E "(permitroot|passwordauth|maxauth)"
```

### Monthly Security Review

```bash
# Generate comprehensive report
./astro report --detailed

# Review banned IPs and patterns
sudo fail2ban-client status sshd

# Audit user accounts
sudo cat /etc/passwd | grep -E "/bin/(bash|sh)"

# Check for unusual processes
ps aux | grep -v "^\[" | sort -k3 -nr | head -20
```

## 🚨 Troubleshooting

### Common Issues

#### SSH Connection Issues

```bash
# If locked out of SSH:
# 1. Use console/KVM access
# 2. Check SSH configuration:
sudo sshd -t

# 3. Restore from backup if needed:
sudo cp /etc/ssh/sshd_config.backup.* /etc/ssh/sshd_config
sudo systemctl restart ssh
```

#### Fail2Ban Not Working

```bash
# Check Fail2Ban status
sudo systemctl status fail2ban

# Check logs
sudo journalctl -u fail2ban

# Restart if needed
sudo systemctl restart fail2ban
```

#### Firewall Blocking Services

```bash
# Check current rules
sudo ufw status numbered

# Remove problematic rule (replace X with rule number)
sudo ufw delete X

# Add correct rule
sudo ufw allow PORT/tcp
```

### Recovery Procedures

#### Complete Security Reset

```bash
# 1. Disable all security measures
sudo systemctl stop fail2ban
sudo ufw disable

# 2. Restore original configurations
sudo cp /etc/ssh/sshd_config.backup.* /etc/ssh/sshd_config
sudo rm -f /etc/fail2ban/jail.local
sudo rm -f /etc/sysctl.d/99-astro-security.conf

# 3. Restart services
sudo systemctl restart ssh
sudo sysctl -p

# 4. Re-run Astro Server when ready
./astro harden
```

## 🎯 Best Practices

### Before Hardening

- [ ] Ensure SSH key access is working
- [ ] Have console/KVM access available
- [ ] Backup important configurations
- [ ] Test in non-production environment first
- [ ] Document current configuration

### After Hardening

- [ ] Test SSH access from new session
- [ ] Verify all required services are accessible
- [ ] Generate and review security report
- [ ] Set up monitoring and alerting
- [ ] Schedule regular security reviews

### Ongoing Maintenance

- [ ] Monitor security reports weekly
- [ ] Review Fail2Ban logs regularly
- [ ] Keep system updated
- [ ] Audit user access quarterly
- [ ] Update security configurations as needed

---

**Your server security journey starts with a single command!** 🚀🛡️

*Need help? Check our [troubleshooting guide](INSTALL.md#troubleshooting) or [open an issue](https://github.com/xploz1on/astro-tech/issues).*
