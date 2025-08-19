# 📦 Astro Server Installation Guide

Complete installation and setup guide for the Astro Server Security Toolkit.

## 🎯 Prerequisites

### System Requirements

- **Operating System**: Linux (Ubuntu 18.04+, Debian 10+)
- **User Account**: Non-root user with sudo privileges
- **Memory**: Minimum 512MB RAM
- **Disk Space**: 100MB free space
- **Network**: Internet connection for package updates

### Required Permissions

```bash
# Verify sudo access
sudo -v

# Check user groups
groups $USER
# Should include: sudo (Ubuntu) or wheel (RHEL/Fedora)
```

## 🚀 Installation Methods

### Method 1: Direct Download (Recommended)

```bash
# Download the toolkit
wget https://github.com/xploz1on/astro-tech/archive/main.zip
unzip main.zip
cd astro-tech-main

# Or clone with git
git clone https://github.com/xploz1on/astro-tech.git
cd astro-tech
```

### Method 2: One-Line Installer *(Coming Soon)*

```bash
curl -sSL https://get.astro-tech.cloud | bash
```

### Method 3: Package Manager *(Coming Soon)*

```bash
# Ubuntu/Debian
sudo apt install astro-server

# Fedora
sudo dnf install astro-server

# Arch Linux
yay -S astro-server
```

## 🛠️ Setup

### 1. Make Scripts Executable

```bash
chmod +x scripts/*.sh
```

### 2. Verify Installation

```bash
./astro version
```

### 3. Run System Check

```bash
./astro check
```

## 🛡️ First Run

### Interactive Setup

```bash
# Run the main launcher script
./astro
```

The script will guide you through:

1. **System Information Review**
2. **Timezone Configuration**
3. **Package Updates**
4. **Security Feature Selection**
5. **Custom Configuration**

### Automated Setup

```bash
# Use predefined configuration
./astro harden --profile web
```

## 📊 Generate Security Report

```bash
# Create markdown security report
./scripts/security-report.sh

# View the report
cat security-check.md
```

## 🔧 Configuration Profiles

### Available Profiles

```bash
astro-server/configs/profiles/
├── minimal.conf          # Basic security hardening
├── web-server.conf       # Web server optimized
├── database.conf         # Database server focused
├── development.conf      # Developer-friendly
└── paranoid.conf         # Maximum security
```

### Using Profiles

```bash
# Apply web server profile
./astro harden --profile web

# Apply custom configuration
./astro harden --config /path/to/custom.conf
```

## 🐧 Distribution-Specific Setup

### Ubuntu/Debian

```bash
# Update package lists
sudo apt update

# Install dependencies
sudo apt install -y curl wget git

# Run Astro Server
./scripts/Astro-server.sh
```

### Fedora *(Coming Soon)*

```bash
# Update system
sudo dnf update

# Install dependencies
sudo dnf install -y curl wget git

# Run Astro Server
./astro harden --profile balanced
```

### RHEL/CentOS *(Coming Soon)*

```bash
# Enable EPEL repository
sudo yum install -y epel-release

# Install dependencies
sudo yum install -y curl wget git

# Run Astro Server
./astro harden --profile balanced
```

## 🔄 Ansible Setup *(Coming Soon)*

### Install Ansible

```bash
# Ubuntu/Debian
sudo apt install -y ansible

# Fedora
sudo dnf install -y ansible

# RHEL/CentOS
sudo yum install -y ansible
```

### Configure Inventory

```bash
# Edit inventory file
vim ansible/inventory/hosts

# Example inventory
[web-servers]
web1.example.com
web2.example.com

[database-servers]
db1.example.com
db2.example.com

[all:vars]
ansible_user=admin
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### Deploy to Multiple Servers

```bash
# Test connectivity
ansible all -m ping

# Deploy security hardening
ansible-playbook ansible/playbooks/harden-servers.yml

# Generate reports
ansible-playbook ansible/playbooks/security-reports.yml
```

## 🔍 Verification

### Check Security Status

```bash
# Generate security report
./astro report

# Check specific services
sudo systemctl status fail2ban
sudo systemctl status ssh
sudo ufw status
```

### Verify SSH Hardening

```bash
# Check SSH configuration
sudo sshd -T | grep -E "(permitrootlogin|passwordauthentication|maxauthtries)"

# Test SSH connection (from another terminal)
ssh -o PreferredAuthentications=password user@localhost
# Should fail if password auth is disabled
```

### Verify Fail2Ban

```bash
# Check Fail2Ban status
sudo fail2ban-client status

# Check SSH jail
sudo fail2ban-client status sshd
```

## 🚨 Troubleshooting

### Common Issues

#### 1. Permission Denied

```bash
# Fix script permissions
chmod +x scripts/*.sh

# Check sudo access
sudo -v
```

#### 2. SSH Lockout Prevention

```bash
# Before hardening, ensure SSH key access works
ssh-copy-id user@server

# Test key-based login
ssh -o PreferredAuthentications=publickey user@server
```

#### 3. Firewall Issues

```bash
# If locked out, use console access
sudo ufw disable

# Reset firewall rules
sudo ufw --force reset
```

#### 4. Service Failures

```bash
# Check service logs
sudo journalctl -u fail2ban
sudo journalctl -u ssh

# Restart services
sudo systemctl restart fail2ban
sudo systemctl restart ssh
```

### Recovery Procedures

#### SSH Configuration Recovery

```bash
# Restore from backup
sudo cp /etc/ssh/sshd_config.backup.* /etc/ssh/sshd_config
sudo systemctl restart ssh
```

#### Fail2Ban Recovery

```bash
# Unban all IPs
sudo fail2ban-client unban --all

# Restart Fail2Ban
sudo systemctl restart fail2ban
```

## 📋 Post-Installation Checklist

- [ ] Scripts are executable
- [ ] System check passes
- [ ] SSH key authentication works
- [ ] Backup access method available (console/KVM)
- [ ] Security report generates successfully
- [ ] All required services are running
- [ ] Firewall rules are appropriate
- [ ] Monitoring is functional

## 🔄 Updates

### Manual Updates

```bash
# Pull latest changes
git pull origin main

# Re-run setup if needed
./astro update
```

### Automatic Updates *(Coming Soon)*

```bash
# Enable auto-updates
./astro update

# Check update status
./astro version
```

## 📞 Support

If you encounter issues:

1. **Check the troubleshooting section above**
2. **Review logs**: `sudo journalctl -u <service>`
3. **Generate debug report**: `./astro check`
4. **Consult documentation**: `astro-server/docs/`
5. **Report issues**: Create a GitHub issue with debug output

---

**Your server security journey starts here!** 🚀🛡️
