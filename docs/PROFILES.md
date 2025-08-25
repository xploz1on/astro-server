# 🛡️ Astro Server Security Profiles

## Overview

Astro Server now supports **5 distinct security profiles** optimized for different server types and use cases. Each profile includes carefully tuned SSH, firewall, and kernel security settings to balance security with functionality.

## 📋 Profile Comparison

| Profile | Security Level | VS Code Support | Password Auth | TCP Forwarding | Best For |
|---------|---------------|-----------------|---------------|----------------|----------|
| **Development** | 🟡 Moderate | ✅ Enabled | ✅ Yes | ✅ Yes | Local development, staging |
| **Production** | 🔴 Maximum | ❌ Disabled | ❌ No | ❌ No | Live production servers |
| **Balanced** | 🟢 High | ❓ Interactive | ❌ No | ❓ Ask | Mixed environments, UAT |
| **Database** | 🔴 Maximum | ❌ Disabled | ❌ No | ❌ No | Database servers |
| **Web Server** | 🟢 High | ❓ Interactive | ❌ No | ❓ Ask | Web applications |

## 🔧 Profile Details

### 1. Development Profile
```bash
ansible-playbook ansible/playbooks/harden-servers.yml -e "astro_security_profile=development"
```

**Purpose**: Optimized for development environments with full VS Code support

**Key Features**:
- ✅ **VS Code Compatible** - Full remote development support
- ✅ **Password Authentication** - Convenient for development teams
- ✅ **TCP Forwarding** - Required for VS Code features
- 🟡 **Moderate Security** - Balanced for development workflow
- 🌐 **Development Ports** - HTTP, Node.js, Python, Java ports open

**Best For**:
- Local development servers
- Testing and staging environments
- Development teams that need VS Code

**Example Usage**:
```bash
# Deploy to development server
ansible-playbook ansible/playbooks/harden-servers.yml \
  -i development-servers.ini \
  -e "astro_security_profile=development"

# VS Code will work immediately after deployment
```

---

### 2. Production Profile
```bash
ansible-playbook ansible/playbooks/harden-servers.yml -e "astro_security_profile=production"
```

**Purpose**: Maximum security for live production servers

**Key Features**:
- ❌ **VS Code Disabled** - Intentionally breaks VS Code for security
- ❌ **Keys Only** - No password authentication
- ❌ **No Forwarding** - TCP and agent forwarding disabled
- 🔴 **Maximum Security** - All hardening features enabled
- 🚫 **Minimal Ports** - SSH only (port 22)

**Best For**:
- Public-facing production servers
- Critical infrastructure
- High-security environments

**⚠️ Important Notes**:
- VS Code remote development **will not work**
- Use local development or deploy with `development` profile for coding
- This is the most secure profile

**Example Usage**:
```bash
# Deploy to production server
ansible-playbook ansible/playbooks/harden-servers.yml \
  -i production-servers.ini \
  -e "astro_security_profile=production"

# VS Code will NOT work - by design
```

---

### 3. Balanced Profile
```bash
ansible-playbook ansible/playbooks/harden-servers.yml -e "astro_security_profile=balanced"
```

**Purpose**: High security with development flexibility - asks about VS Code

**Key Features**:
- ❓ **Interactive VS Code** - Prompts during deployment
- ❌ **Keys Only** - No password authentication
- ❓ **Conditional Forwarding** - Based on your VS Code choice
- 🟢 **High Security** - Strong protection with flexibility
- 🌐 **Essential Ports** - SSH, HTTP, HTTPS

**Best For**:
- Internal tools and applications
- User acceptance testing (UAT)
- Mixed development/production environments

**Interactive Prompt**:
```
Do you want to enable VS Code remote development support?
This will configure TCP forwarding for VS Code connections.

WARNING: Enabling this reduces security for development convenience

Options:
- 'yes' or 'y': Enable VS Code support (allows TCP forwarding)
- 'no' or 'n': Disable VS Code support (maximum security)
- Press Enter for profile default

Your choice:
```

**Example Usage**:
```bash
# Deploy with interactive VS Code prompt
ansible-playbook ansible/playbooks/harden-servers.yml \
  -i staging-servers.ini \
  -e "astro_security_profile=balanced"

# You'll be prompted about VS Code during deployment
```

---

### 4. Database Profile
```bash
ansible-playbook ansible/playbooks/harden-servers.yml -e "astro_security_profile=database"
```

**Purpose**: Maximum security optimized for database servers

**Key Features**:
- ❌ **VS Code Disabled** - Security takes priority
- ❌ **Keys Only** - No password authentication
- ❌ **No Forwarding** - All forwarding disabled
- 🔴 **Database Ports** - MySQL, PostgreSQL, MongoDB, Redis
- 🚫 **Restricted Access** - Source IP restrictions on database ports

**Best For**:
- MySQL/MariaDB servers
- PostgreSQL servers
- MongoDB servers
- Redis servers
- Any sensitive data storage

**Security Features**:
- Database-specific firewall rules
- Enhanced monitoring for database connections
- Restricted network access (10.0.0.0/8 by default)
- Automatic backup validation

**Example Usage**:
```bash
# Deploy to database server
ansible-playbook ansible/playbooks/harden-servers.yml \
  -i database-servers.ini \
  -e "astro_security_profile=database"

# VS Code will NOT work - by design for security
```

---

### 5. Web Server Profile
```bash
ansible-playbook ansible/playbooks/harden-servers.yml -e "astro_security_profile=webserver"
```

**Purpose**: High security optimized for web applications

**Key Features**:
- ❓ **Interactive VS Code** - Prompts during deployment
- ❌ **Keys Only** - No password authentication
- ❓ **Conditional Forwarding** - Based on your choice
- 🌐 **Web Ports** - HTTP (80), HTTPS (443), alternative ports
- 🛡️ **Rate Limiting** - Built-in DDoS protection

**Best For**:
- Apache HTTP servers
- Nginx servers
- Node.js applications
- PHP applications
- Static website servers

**Interactive Prompt**: Same as Balanced profile

**Additional Features**:
- SSL certificate configuration
- Web server monitoring
- Response time tracking
- Automatic Let's Encrypt setup

**Example Usage**:
```bash
# Deploy to web server
ansible-playbook ansible/playbooks/harden-servers.yml \
  -i web-servers.ini \
  -e "astro_security_profile=webserver"

# You'll be prompted about VS Code during deployment
```

## 🚀 Quick Profile Selection

### Command Line Examples

```bash
# Development (full VS Code support)
ansible-playbook ansible/playbooks/harden-servers.yml -e "astro_security_profile=development"

# Production (maximum security, no VS Code)
ansible-playbook ansible/playbooks/harden-servers.yml -e "astro_security_profile=production"

# Balanced (asks about VS Code)
ansible-playbook ansible/playbooks/harden-servers.yml -e "astro_security_profile=balanced"

# Database (secure database server)
ansible-playbook ansible/playbooks/harden-servers.yml -e "astro_security_profile=database"

# Web Server (asks about VS Code)
ansible-playbook ansible/playbooks/harden-servers.yml -e "astro_security_profile=webserver"
```

### Ansible Inventory Examples

```ini
# inventory.ini
[development]
dev-server-01
dev-server-02

[production]
prod-web-01
prod-db-01

[staging]
staging-server-01

[database]
db-server-01
db-server-02
```

```bash
# Deploy different profiles to different groups
ansible-playbook ansible/playbooks/harden-servers.yml \
  -i inventory.ini \
  -l development \
  -e "astro_security_profile=development"

ansible-playbook ansible/playbooks/harden-servers.yml \
  -i inventory.ini \
  -l production \
  -e "astro_security_profile=production"
```

## 💻 VS Code Compatibility Matrix

| Profile | VS Code Works? | TCP Forwarding | When to Use |
|---------|----------------|----------------|-------------|
| Development | ✅ Yes | ✅ Enabled | Always use for development |
| Production | ❌ No | ❌ Disabled | Never - by design |
| Balanced | ❓ Ask during deploy | ❓ Your choice | When you might need VS Code |
| Database | ❌ No | ❌ Disabled | Never - security first |
| Web Server | ❓ Ask during deploy | ❓ Your choice | When developing on web servers |

## 🔍 Profile Selection Guide

### Choose Development If:
- You need full VS Code remote development
- It's a development or staging environment
- Team members need convenient access
- Security is less critical than functionality

### Choose Production If:
- It's a live production server
- Maximum security is the highest priority
- VS Code access is not needed
- It's public-facing or contains sensitive data

### Choose Balanced If:
- You want high security but might need VS Code
- It's an internal server or UAT environment
- You want to decide per deployment
- You need flexibility between security and development

### Choose Database If:
- It's running database software (MySQL, PostgreSQL, etc.)
- It contains sensitive data
- You need database-specific monitoring
- Maximum security is required

### Choose Web Server If:
- It's running web applications (Apache, Nginx, Node.js)
- You need web-specific monitoring
- You might need VS Code for web development
- You want rate limiting and SSL support

## ⚙️ Customizing Profiles

### Override Profile Settings
```yaml
# Override specific settings
ansible-playbook ansible/playbooks/harden-servers.yml \
  -e "astro_security_profile=production" \
  -e "astro_ssh_port=2222" \
  -e "enable_tcp_forwarding=true"
```

### Create Custom Profiles
```bash
# Create your own profile file
cp ansible/group_vars/balanced.yml ansible/group_vars/custom.yml

# Edit settings in custom.yml
vim ansible/group_vars/custom.yml

# Use your custom profile
ansible-playbook ansible/playbooks/harden-servers.yml \
  -e "astro_security_profile=custom"
```

## 🔒 Security Best Practices by Profile

### Development Profile
- ✅ Use strong passwords
- ✅ Enable 2FA where possible
- ✅ Regular security updates
- ✅ Monitor logs for suspicious activity

### Production Profile
- ✅ Use SSH keys only (no passwords)
- ✅ Regular security audits
- ✅ Monitor all access attempts
- ✅ Implement least privilege access

### Balanced Profile
- ✅ Keys only authentication
- ✅ Review VS Code decisions per deployment
- ✅ Regular security assessments
- ✅ Monitor for unusual activity

### Database Profile
- ✅ Restrict network access to database ports
- ✅ Regular backup validation
- ✅ Monitor connection attempts
- ✅ Implement query logging

### Web Server Profile
- ✅ Enable SSL/TLS encryption
- ✅ Implement rate limiting
- ✅ Regular SSL certificate renewal
- ✅ Monitor web application logs

## 📊 Monitoring and Reporting

Each profile includes optimized monitoring and reporting:

- **Development**: Basic monitoring with development focus
- **Production**: Comprehensive monitoring with security alerts
- **Balanced**: Standard monitoring with flexibility
- **Database**: Database-specific monitoring and connection tracking
- **Web Server**: Web metrics, SSL status, and performance monitoring

## 🆘 Troubleshooting

### VS Code Not Working
- **Check Profile**: Ensure you're not using `production` or `database` profiles
- **Verify Settings**: Run security report to check TCP forwarding status
- **Redeploy**: Switch to `development` profile for full VS Code support

### Profile Not Applying
- **Check Syntax**: Verify profile name is spelled correctly
- **Inventory**: Ensure target hosts are in correct inventory groups
- **Variables**: Check for variable conflicts in group_vars

### Interactive Prompts Not Showing
- **Check Profile**: Only `balanced` and `webserver` profiles show VS Code prompts
- **Variable Override**: Ensure `ask_vscode_support` is not pre-set

## 📞 Support

For questions about profile selection or customization:

- 📖 **Documentation**: Check this guide and related docs
- 🐛 **Issues**: Report bugs on GitHub
- 💬 **Discussions**: Join community discussions
- 📧 **Security**: Contact for security-related concerns

---

## 🎯 Next Steps

1. **Choose Your Profile**: Based on your server type and needs
2. **Deploy**: Use the appropriate Ansible command
3. **Verify**: Run the security report to confirm settings
4. **Test**: Verify VS Code connectivity (if applicable)
5. **Monitor**: Use the automated reporting for ongoing security

Remember: **Security is a balance**. Choose the profile that best fits your security requirements while supporting your workflow needs.
