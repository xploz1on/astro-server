# 🤖 Ansible Usage Guide

Complete guide for deploying Astro Server across multiple servers using Ansible automation.

## 🎯 Overview

Ansible mode enables:

- **Multi-server deployments** - Secure hundreds of servers simultaneously
- **Infrastructure as Code** - Version-controlled security configurations
- **Consistent hardening** - Identical security across all environments
- **Automated reporting** - Centralized security status collection
- **Environment management** - Different configs for dev/staging/production
- **Compliance automation** - Audit-ready deployment tracking

## 📋 Prerequisites

### System Requirements

```bash
# Control Machine (where you run Ansible)
- Ansible 2.9+ installed
- SSH key access to target servers
- Python 3.6+ 
- Git (for cloning repository)

# Target Servers
- Linux (Ubuntu 18.04+, Debian 10+, RHEL 8+, Fedora 35+)
- SSH access enabled
- Sudo privileges for deployment user
- Python 3.x installed
```

### Install Ansible

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install ansible

# RHEL/CentOS/Fedora  
sudo dnf install ansible

# macOS
brew install ansible

# Python pip (universal)
pip3 install ansible

# Verify installation
ansible --version
```

## 🚀 Quick Start

### 1. Setup Project

```bash
# Clone Astro Server
git clone https://github.com/xploz1on/astro-tech.git
cd astro-tech

# Verify Ansible components
ls ansible/
# playbooks/  inventory/  group_vars/  roles/
```

### 2. Configure Inventory

```bash
# Copy example inventory
cp ansible/inventory/hosts.example ansible/inventory/hosts

# Edit for your environment
vim ansible/inventory/hosts
```

### 3. Test Connectivity

```bash
# Test connection to all servers
ansible all -i ansible/inventory/hosts -m ping

# Expected output:
# web1.example.com | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }
```

### 4. Deploy Security Hardening

```bash
# Deploy to all servers
./astro deploy --inventory ansible/inventory/hosts

# Deploy to specific groups
./astro deploy --limit web-servers

# Dry run (check mode)
./astro deploy --check
```

## 📁 Inventory Configuration

### Basic Inventory Structure

```ini
# ansible/inventory/hosts

[web-servers]
web1.example.com ansible_host=192.168.1.10
web2.example.com ansible_host=192.168.1.11
web3.example.com ansible_host=192.168.1.12

[database-servers]
db1.example.com ansible_host=192.168.1.20
db2.example.com ansible_host=192.168.1.21

[monitoring-servers]
monitor1.example.com ansible_host=192.168.1.30

# Group all production servers
[production:children]
web-servers
database-servers
monitoring-servers

[development]
dev1.example.com ansible_host=192.168.1.40
dev2.example.com ansible_host=192.168.1.41

# Global variables
[all:vars]
ansible_user=admin
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

### Advanced Inventory with Groups

```ini
# Production Environment
[prod-web]
web[1:3].prod.example.com

[prod-db]  
db[1:2].prod.example.com

[prod-cache]
redis[1:3].prod.example.com

[production:children]
prod-web
prod-db
prod-cache

# Staging Environment
[staging-web]
web[1:2].staging.example.com

[staging-db]
db1.staging.example.com

[staging:children]
staging-web
staging-db

# Development Environment
[development]
dev[1:5].dev.example.com

# Security Profiles by Group
[high-security:children]
prod-db
prod-cache

[standard-security:children]
prod-web
staging

[minimal-security:children]
development
```

## ⚙️ Configuration Management

### Group Variables

Edit `ansible/group_vars/all.yml` for global settings:

```yaml
---
# Global Security Settings
astro_security_profile: balanced
astro_enable_fail2ban: true
astro_enable_firewall: true
astro_ssh_port: 22

# SSH Configuration
ssh_config:
  permit_root_login: "no"
  password_authentication: "no"
  max_auth_tries: 3
  client_alive_interval: 300

# Fail2Ban Settings
fail2ban_config:
  ban_time: 3600        # 1 hour
  find_time: 600        # 10 minutes  
  max_retry: 3          # 3 attempts
  mode: "aggressive"
```

### Environment-Specific Variables

Create group-specific configurations:

```bash
# Production settings
# ansible/group_vars/production.yml
---
astro_security_profile: aggressive
fail2ban_config:
  ban_time: 86400       # 24 hours
  max_retry: 2          # 2 attempts
firewall_rules:
  - { port: "22", proto: "tcp", comment: "SSH" }
  - { port: "80", proto: "tcp", comment: "HTTP" }
  - { port: "443", proto: "tcp", comment: "HTTPS" }

# Development settings  
# ansible/group_vars/development.yml
---
astro_security_profile: minimal
fail2ban_config:
  ban_time: 1800        # 30 minutes
  max_retry: 5          # 5 attempts
astro_enable_firewall: false
```

### Host-Specific Variables

For individual server customization:

```bash
# ansible/host_vars/web1.example.com.yml
---
# Custom SSH port for this server
astro_ssh_port: 2222

# Additional firewall rules
firewall_custom_rules:
  - { port: "8080", proto: "tcp", comment: "Custom App" }
  - { port: "9090", proto: "tcp", source: "10.0.0.0/8", comment: "Monitoring" }

# Custom Fail2Ban settings
fail2ban_config:
  ban_time: 7200        # 2 hours for this high-traffic server
```

## 🚀 Deployment Scenarios

### Scenario 1: New Infrastructure Deployment

```bash
# 1. Deploy base security to all servers
./astro deploy --inventory production.hosts

# 2. Apply web-specific hardening
./astro deploy --limit web-servers --extra-vars "astro_security_profile=web-server"

# 3. Apply database-specific hardening  
./astro deploy --limit database-servers --extra-vars "astro_security_profile=database"

# 4. Generate reports for all servers
ansible-playbook -i production.hosts ansible/playbooks/security-reports.yml
```

### Scenario 2: Gradual Production Rollout

```bash
# 1. Test on single server first
./astro deploy --limit web1.example.com --check

# 2. Deploy to one server
./astro deploy --limit web1.example.com

# 3. Verify and test
ansible web1.example.com -i production.hosts -m shell -a "systemctl status fail2ban"

# 4. Deploy to remaining web servers
./astro deploy --limit web-servers:!web1.example.com

# 5. Deploy to database servers
./astro deploy --limit database-servers
```

### Scenario 3: Emergency Security Response

```bash
# Rapid deployment across all servers
./astro deploy --inventory all-servers.hosts --extra-vars "astro_security_profile=paranoid"

# Immediate ban of specific IP across all servers
ansible all -i all-servers.hosts -m shell -a "fail2ban-client set sshd banip 1.2.3.4"

# Generate emergency security reports
ansible-playbook -i all-servers.hosts ansible/playbooks/emergency-audit.yml
```

## 📊 Automated Reporting

### Generate Security Reports

```bash
# Generate reports for all servers
ansible-playbook -i inventory/hosts ansible/playbooks/security-reports.yml

# Generate reports for specific group
ansible-playbook -i inventory/hosts ansible/playbooks/security-reports.yml --limit web-servers

# Collect reports locally
ansible all -i inventory/hosts -m fetch -a "src=/home/admin/security-check.md dest=./reports/ flat=yes"
```

### Report Aggregation

The reports are automatically collected to `./reports/` directory:

```
reports/
├── web1.example.com-security-report.md
├── web2.example.com-security-report.md  
├── db1.example.com-security-report.md
└── summary-report.md
```

### Automated Report Generation

Set up daily report generation:

```yaml
# ansible/playbooks/daily-reports.yml
---
- name: Daily Security Reports
  hosts: all
  tasks:
    - name: Generate security report
      script: ../scripts/security-report.sh
      
    - name: Fetch reports
      fetch:
        src: "/home/{{ ansible_user }}/security-check.md"
        dest: "./reports/{{ inventory_hostname }}-{{ ansible_date_time.date }}.md"
        flat: yes
```

Run with cron:
```bash
# Add to crontab
0 6 * * * cd /path/to/astro-server && ansible-playbook -i inventory/hosts ansible/playbooks/daily-reports.yml
```

## 🔧 Advanced Playbook Usage

### Custom Playbook Execution

```bash
# Run specific playbook
ansible-playbook -i inventory/hosts ansible/playbooks/harden-servers.yml

# With extra variables
ansible-playbook -i inventory/hosts ansible/playbooks/harden-servers.yml \
  --extra-vars "astro_security_profile=aggressive astro_enable_firewall=true"

# Limit to specific hosts
ansible-playbook -i inventory/hosts ansible/playbooks/harden-servers.yml \
  --limit "web-servers:&production"

# Check mode (dry run)
ansible-playbook -i inventory/hosts ansible/playbooks/harden-servers.yml --check

# Step-by-step execution
ansible-playbook -i inventory/hosts ansible/playbooks/harden-servers.yml --step
```

### Playbook Tags

Use tags for selective execution:

```bash
# Only run SSH hardening
ansible-playbook -i inventory/hosts ansible/playbooks/harden-servers.yml --tags ssh

# Only run Fail2Ban configuration
ansible-playbook -i inventory/hosts ansible/playbooks/harden-servers.yml --tags fail2ban

# Skip firewall configuration
ansible-playbook -i inventory/hosts ansible/playbooks/harden-servers.yml --skip-tags firewall
```

### Parallel Execution

```bash
# Run on 10 servers simultaneously
ansible-playbook -i inventory/hosts ansible/playbooks/harden-servers.yml --forks 10

# Serial execution (one server at a time)
ansible-playbook -i inventory/hosts ansible/playbooks/harden-servers.yml --serial 1

# Batch execution (25% at a time)
ansible-playbook -i inventory/hosts ansible/playbooks/harden-servers.yml --serial 25%
```

## 🔍 Monitoring and Validation

### Post-Deployment Validation

```bash
# Verify SSH hardening
ansible all -i inventory/hosts -m shell -a "sshd -T | grep -E '(permitroot|passwordauth)'"

# Check Fail2Ban status
ansible all -i inventory/hosts -m shell -a "fail2ban-client status"

# Verify firewall status
ansible all -i inventory/hosts -m shell -a "ufw status" --become

# Check system updates
ansible all -i inventory/hosts -m shell -a "apt list --upgradable | wc -l"
```

### Continuous Monitoring

```bash
# Check for failed login attempts
ansible all -i inventory/hosts -m shell -a "journalctl -u ssh --since '24 hours ago' | grep -c 'Failed password'"

# Monitor banned IPs
ansible all -i inventory/hosts -m shell -a "fail2ban-client status sshd | grep 'Banned IP list'"

# System resource monitoring
ansible all -i inventory/hosts -m shell -a "uptime && free -h && df -h /"
```

## 🚨 Troubleshooting

### Common Ansible Issues

#### Connection Problems

```bash
# Test basic connectivity
ansible all -i inventory/hosts -m ping

# Test with verbose output
ansible all -i inventory/hosts -m ping -vvv

# Test SSH connection manually
ssh -i ~/.ssh/id_rsa admin@server.example.com
```

#### Permission Issues

```bash
# Test sudo access
ansible all -i inventory/hosts -m shell -a "sudo whoami" --become

# Check sudo configuration
ansible all -i inventory/hosts -m shell -a "sudo -l"
```

#### Playbook Failures

```bash
# Run with maximum verbosity
ansible-playbook -i inventory/hosts playbook.yml -vvv

# Check syntax
ansible-playbook --syntax-check playbook.yml

# Dry run to see what would change
ansible-playbook -i inventory/hosts playbook.yml --check --diff
```

### Recovery Procedures

#### Rollback Security Changes

```bash
# Rollback playbook (if implemented)
ansible-playbook -i inventory/hosts ansible/playbooks/rollback-security.yml

# Manual rollback of specific components
ansible all -i inventory/hosts -m shell -a "systemctl stop fail2ban" --become
ansible all -i inventory/hosts -m shell -a "ufw disable" --become
```

#### Emergency Access Recovery

```bash
# Disable Fail2Ban on all servers
ansible all -i inventory/hosts -m service -a "name=fail2ban state=stopped" --become

# Reset firewall rules
ansible all -i inventory/hosts -m shell -a "ufw --force reset" --become

# Restore SSH configuration from backup
ansible all -i inventory/hosts -m shell -a "cp /etc/ssh/sshd_config.backup.* /etc/ssh/sshd_config" --become
```

## 🎯 Best Practices

### Pre-Deployment Checklist

- [ ] Test playbooks in development environment
- [ ] Verify SSH key access to all servers
- [ ] Backup critical configurations
- [ ] Have console/KVM access available
- [ ] Plan rollback procedures
- [ ] Coordinate with team members

### Deployment Strategy

- [ ] Start with non-production environments
- [ ] Deploy to small batches of servers
- [ ] Validate each batch before proceeding
- [ ] Monitor logs during deployment
- [ ] Generate reports after completion

### Post-Deployment

- [ ] Verify all services are accessible
- [ ] Test application functionality
- [ ] Generate and review security reports
- [ ] Update documentation
- [ ] Schedule regular security audits

### Ongoing Management

- [ ] Regular playbook updates
- [ ] Automated security reporting
- [ ] Periodic access reviews
- [ ] Configuration drift detection
- [ ] Compliance monitoring

## 📈 Scaling Considerations

### Large Deployments (100+ servers)

```bash
# Use dynamic inventory
ansible-playbook -i inventory/dynamic.py playbook.yml

# Increase parallelism
ansible-playbook -i inventory/hosts playbook.yml --forks 50

# Use batch processing
ansible-playbook -i inventory/hosts playbook.yml --serial 10%

# Enable pipelining for speed
# In ansible.cfg:
# [ssh_connection]
# pipelining = True
```

### Multi-Region Deployments

```bash
# Region-specific inventories
ansible-playbook -i inventory/us-east.hosts playbook.yml
ansible-playbook -i inventory/eu-west.hosts playbook.yml
ansible-playbook -i inventory/asia-pacific.hosts playbook.yml

# Parallel region deployment
ansible-playbook -i inventory/all-regions.hosts playbook.yml --limit us-east &
ansible-playbook -i inventory/all-regions.hosts playbook.yml --limit eu-west &
ansible-playbook -i inventory/all-regions.hosts playbook.yml --limit asia-pacific &
wait
```

---

**Scale your security across thousands of servers with confidence!** 🚀🛡️

Need help? Check our [troubleshooting section](#🚨-troubleshooting) or [open an issue](https://github.com/xploz1on/astro-tech/issues).
