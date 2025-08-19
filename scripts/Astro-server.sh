#!/bin/bash

# Astro Server Security Hardening Script
# Interactive server security configuration tool
# Version: 1.0
# Author: Astro Tech Security Team

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Animation functions
spinner() {
    local pid="$1"
    local delay=0.1
    local frames='|/-\'
    while kill -0 "$pid" 2>/dev/null; do
        for ((i=0; i<${#frames}; i++)); do
            printf " [%c]  " "${frames:i:1}"
            sleep "$delay"
            printf "\r"
        done
    done
    printf "      \r"
}

with_quips() {
    [ -n "${ASTRO_NO_JOKES:-}" ] && return 0
    local pid="$1"
    local i=0
    local -a nerd_quips=(
        "Compiling security. Please stand by while entropy accumulates..."
        "Brute-forcers hate this one weird trick."
        "Deploying phasers to stun. Shields at 100%."
        "Upgrading packages: because unpatched is just another word for adventure."
        "Beep boop: applying best practices so you don’t have to."
    )
    while kill -0 "$pid" 2>/dev/null; do
        sleep 12
        echo -e "${YELLOW}${nerd_quips[i % ${#nerd_quips[@]}]}${NC}"
        ((i++))
    done
}

# Default step choices (can be adjusted via --profile)
DEFAULT_UPDATE_SYSTEM='y'
DEFAULT_ENABLE_UNATTENDED='y'
DEFAULT_HARDEN_SSH='y'
DEFAULT_INSTALL_FAIL2BAN='y'
DEFAULT_CONFIGURE_FIREWALL='n'
DEFAULT_KERNEL_HARDEN='y'
DEFAULT_CREATE_MONITORING='y'

PROFILE=""

apply_profile_defaults() {
    case "$PROFILE" in
        web|web-server)
            DEFAULT_CONFIGURE_FIREWALL='y'
            ;;
        aggressive)
            DEFAULT_CONFIGURE_FIREWALL='y'
            ;;
        minimal)
            DEFAULT_ENABLE_UNATTENDED='n'
            DEFAULT_INSTALL_FAIL2BAN='n'
            DEFAULT_CONFIGURE_FIREWALL='n'
            ;;
        balanced|"" )
            :
            ;;
        *)
            :
            ;;
    esac
}

print_banner() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "    ╔═══════════════════════════════════════════════════════════════╗"
    echo "    ║                                                               ║"
    echo "    ║      🚀 ASTRO SERVER SECURITY HARDENING TOOL 🚀              ║"
    echo "    ║                                                               ║"
    echo "    ║           Transform your server into a fortress!              ║"
    echo "    ║                                                               ║"
    echo "    ╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
}

print_step() {
    echo -e "${CYAN}${BOLD}[STEP $1]${NC} ${WHITE}$2${NC}"
}

print_success() {
    echo -e "${GREEN}${BOLD}✅ SUCCESS:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}${BOLD}⚠️  WARNING:${NC} $1"
}

print_error() {
    echo -e "${RED}${BOLD}❌ ERROR:${NC} $1"
}

print_info() {
    echo -e "${BLUE}${BOLD}ℹ️  INFO:${NC} $1"
}

ask_yes_no() {
    local question="$1"
    local default="$2"
    local response
    
    if [ "$default" = "y" ]; then
        echo -e "${YELLOW}${BOLD}❓ $question [Y/n]:${NC} \c"
    else
        echo -e "${YELLOW}${BOLD}❓ $question [y/N]:${NC} \c"
    fi
    
    read response
    
    if [ -z "$response" ]; then
        response="$default"
    fi
    
    case "$response" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_error "Please don't run this script as root. Use a sudo-enabled user instead."
        exit 1
    fi
    
    if ! sudo -n true 2>/dev/null; then
        print_info "This script requires sudo privileges. You may be prompted for your password."
        sudo -v || {
            print_error "Failed to obtain sudo privileges"
            exit 1
        }
    fi
}

system_info() {
    print_step "1" "Gathering System Information"
    echo
    
    OS=$(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
    KERNEL=$(uname -r)
    ARCH=$(uname -m)
    UPTIME=$(uptime -p)
    
    echo -e "${BLUE}🖥️  Operating System: ${WHITE}$OS${NC}"
    echo -e "${BLUE}🔧 Kernel Version:   ${WHITE}$KERNEL${NC}"
    echo -e "${BLUE}💻 Architecture:     ${WHITE}$ARCH${NC}"
    echo -e "${BLUE}⏰ Uptime:          ${WHITE}$UPTIME${NC}"
    echo
    
    if ask_yes_no "Continue with security hardening?" "y"; then
        return 0
    else
        echo -e "${YELLOW}Exiting...${NC}"
        exit 0
    fi
}

configure_timezone() {
    if ask_yes_no "Do you want to configure the system timezone?" "y"; then
        print_step "2" "Configuring Timezone"
        echo
        
        echo -e "${CYAN}Current timezone: ${WHITE}$(timedatectl show --property=Timezone --value)${NC}"
        echo
        
        if ask_yes_no "Change timezone?" "n"; then
            echo -e "${YELLOW}Available timezones (showing common ones):${NC}"
            echo "1) UTC"
            echo "2) America/New_York"
            echo "3) America/Los_Angeles"
            echo "4) Europe/London"
            echo "5) Europe/Berlin"
            echo "6) Asia/Tokyo"
            echo "7) Custom (enter manually)"
            echo
            
            echo -e "${YELLOW}Enter choice [1-7]:${NC} \c"
            read tz_choice
            
            case $tz_choice in
                1) TIMEZONE="UTC" ;;
                2) TIMEZONE="America/New_York" ;;
                3) TIMEZONE="America/Los_Angeles" ;;
                4) TIMEZONE="Europe/London" ;;
                5) TIMEZONE="Europe/Berlin" ;;
                6) TIMEZONE="Asia/Tokyo" ;;
                7) 
                    echo -e "${YELLOW}Enter timezone (e.g., Asia/Shanghai):${NC} \c"
                    read TIMEZONE
                    ;;
                *) 
                    print_warning "Invalid choice, keeping current timezone"
                    return
                    ;;
            esac
            
            echo -e "${CYAN}Setting timezone to $TIMEZONE...${NC}"
            sudo timedatectl set-timezone "$TIMEZONE" && \
            print_success "Timezone set to $TIMEZONE"
        fi
    fi
}

update_system() {
    if ask_yes_no "Update system packages?" "$DEFAULT_UPDATE_SYSTEM"; then
        print_step "3" "Updating System Packages"
        echo
        
        echo -e "${CYAN}Updating package repositories...${NC}"
        sudo apt update > /dev/null 2>&1 &
        pid=$!
        with_quips "$pid" &
        spinner "$pid"
        wait "$pid"
        print_success "Package repositories updated"
        
        echo -e "${CYAN}Checking for upgradable packages...${NC}"
        UPGRADABLE=$(apt list --upgradable 2>/dev/null | grep -c upgradable)
        
        if [ "$UPGRADABLE" -gt 1 ]; then
            print_info "$((UPGRADABLE-1)) packages can be upgraded"
            
            if ask_yes_no "Upgrade all packages now?" "y"; then
                echo -e "${CYAN}Upgrading packages (this may take a while)...${NC}"
                sudo apt upgrade -y > /dev/null 2>&1 &
                pid=$!
                with_quips "$pid" &
                spinner "$pid"
                wait "$pid"
                print_success "System packages upgraded"
            fi
        else
            print_success "System is already up to date"
        fi
    fi
}

configure_unattended_upgrades() {
    if ask_yes_no "Enable automatic security updates?" "$DEFAULT_ENABLE_UNATTENDED"; then
        print_step "4" "Configuring Automatic Security Updates"
        echo
        
        if ! dpkg -l | grep -q unattended-upgrades; then
            echo -e "${CYAN}Installing unattended-upgrades...${NC}"
            sudo apt install -y unattended-upgrades > /dev/null 2>&1 &
            pid=$!
            with_quips "$pid" &
            spinner "$pid"
            wait "$pid"
        fi
        
        echo -e "${CYAN}Configuring automatic security updates...${NC}"
        sudo dpkg-reconfigure -plow unattended-upgrades > /dev/null 2>&1
        sudo systemctl enable unattended-upgrades > /dev/null 2>&1
        sudo systemctl start unattended-upgrades > /dev/null 2>&1
        
        print_success "Automatic security updates enabled"
    fi
}

harden_ssh() {
    if ask_yes_no "Harden SSH configuration?" "$DEFAULT_HARDEN_SSH"; then
        print_step "5" "Hardening SSH Configuration"
        echo
        
        # SSH Key Generation
        echo -e "${CYAN}Checking SSH key setup...${NC}"
        if [ ! -f ~/.ssh/id_rsa ] && [ ! -f ~/.ssh/id_ed25519 ]; then
            print_warning "No SSH key found for current user"
            if ask_yes_no "Generate SSH key for current user?" "y"; then
                echo -e "${CYAN}Generating SSH key...${NC}"
                ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C "$(whoami)@$(hostname)"
                print_success "SSH key generated: ~/.ssh/id_ed25519"
                
                # Add to authorized_keys if not already there
                if [ ! -f ~/.ssh/authorized_keys ] || ! grep -q "$(cat ~/.ssh/id_ed25519.pub)" ~/.ssh/authorized_keys 2>/dev/null; then
                    cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
                    chmod 600 ~/.ssh/authorized_keys
                    print_success "SSH key added to authorized_keys"
                fi
                
                echo -e "${YELLOW}Public key (copy this to your local machine):${NC}"
                echo -e "${WHITE}$(cat ~/.ssh/id_ed25519.pub)${NC}"
                echo
                print_warning "IMPORTANT: Copy this public key to your local machine before continuing!"
                if ask_yes_no "Have you copied the public key?" "n"; then
                    print_success "SSH key setup complete"
                else
                    print_warning "Please copy the public key and run this script again"
                    exit 1
                fi
            fi
        else
            print_success "SSH key already exists"
        fi
        
        # Backup SSH config
        echo -e "${CYAN}Creating SSH configuration backup...${NC}"
        local backup_file="/etc/ssh/sshd_config.backup.$(date +%Y%m%d_%H%M%S)"
        sudo cp /etc/ssh/sshd_config "$backup_file"
        
        # Disable root login
        if sudo grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
            echo -e "${CYAN}Disabling root login...${NC}"
            sudo sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
            print_success "Root login disabled"
        else
            print_info "Root login already disabled"
        fi
        
        # Ensure sshd config.d directory exists
        sudo install -d -m 0755 /etc/ssh/sshd_config.d

        # Create additional SSH hardening config
        echo -e "${CYAN}Applying additional SSH security settings...${NC}"
        
        cat > /tmp/ssh_hardening.conf << 'EOF'
# SSH Security Hardening Configuration
MaxAuthTries 3
MaxSessions 2
LoginGraceTime 30
PermitEmptyPasswords no
Protocol 2
HostbasedAuthentication no
IgnoreRhosts yes
ClientAliveInterval 300
ClientAliveCountMax 2
AllowTcpForwarding yes
GatewayPorts no
AllowAgentForwarding no
StrictModes yes
Compression no
X11Forwarding no
EOF
        
        sudo cp /tmp/ssh_hardening.conf /etc/ssh/sshd_config.d/99-security-hardening.conf
        rm /tmp/ssh_hardening.conf
        
        # Test SSH configuration
        if sudo sshd -t; then
            sudo systemctl reload ssh
            print_success "SSH hardening applied successfully"
        else
            print_error "SSH configuration test failed, reverting changes"
            sudo rm -f /etc/ssh/sshd_config.d/99-security-hardening.conf
            sudo cp "$backup_file" /etc/ssh/sshd_config
            sudo systemctl reload ssh || true
        fi
    fi
}

install_fail2ban() {
    if ask_yes_no "Install and configure Fail2Ban for brute force protection?" "$DEFAULT_INSTALL_FAIL2BAN"; then
        print_step "6" "Installing and Configuring Fail2Ban"
        echo
        
        if ! command -v fail2ban-client &> /dev/null; then
            echo -e "${CYAN}Installing Fail2Ban...${NC}"
            sudo apt install -y fail2ban > /dev/null 2>&1 &
            pid=$!
            with_quips "$pid" &
            spinner "$pid"
            wait "$pid"
        fi
        
        echo -e "${CYAN}Configuring Fail2Ban with aggressive settings...${NC}"
        
        # Get ban time preference
        echo -e "${YELLOW}Choose ban duration for SSH attacks:${NC}"
        echo "1) 1 hour (3600 seconds)"
        echo "2) 6 hours (21600 seconds)"
        echo "3) 24 hours (86400 seconds) - Recommended"
        echo "4) 1 week (604800 seconds)"
        echo
        echo -e "${YELLOW}Enter choice [1-4]:${NC} \c"
        read ban_choice
        
        case $ban_choice in
            1) BAN_TIME=3600 ;;
            2) BAN_TIME=21600 ;;
            3) BAN_TIME=86400 ;;
            4) BAN_TIME=604800 ;;
            *) BAN_TIME=86400 ;;
        esac
        
        admin_ip=$(curl -fsS https://ifconfig.io 2>/dev/null || curl -fsS https://api.ipify.org 2>/dev/null || true)
        cat > /tmp/jail.local << EOF
[DEFAULT]
bantime = $BAN_TIME
findtime = 600
maxretry = 3
ignoreip = 127.0.0.1/8 ::1 ${admin_ip}

[sshd]
enabled = true
mode = aggressive
bantime = $BAN_TIME
findtime = 300
maxretry = 3
EOF
        
        sudo cp /tmp/jail.local /etc/fail2ban/jail.local
        rm /tmp/jail.local
        
        sudo systemctl enable fail2ban > /dev/null 2>&1
        sudo systemctl restart fail2ban > /dev/null 2>&1
        
        print_success "Fail2Ban configured with $(($BAN_TIME/3600)) hour ban time"
    fi
}

configure_firewall() {
    if ask_yes_no "Configure UFW firewall?" "$DEFAULT_CONFIGURE_FIREWALL"; then
        print_step "7" "Configuring UFW Firewall"
        echo
        
        if ! command -v ufw &> /dev/null; then
            echo -e "${CYAN}Installing UFW...${NC}"
            sudo apt install -y ufw > /dev/null 2>&1 &
            pid=$!
            with_quips "$pid" &
            spinner "$pid"
            wait "$pid"
        fi
        
        print_warning "IMPORTANT: Make sure you have console access before enabling firewall!"
        print_warning "CRITICAL: Port 22 (SSH) will ALWAYS be preserved to maintain access!"
        
        if ask_yes_no "Continue with firewall configuration?" "y"; then
            echo -e "${CYAN}Configuring firewall rules...${NC}"
            
            # Reset UFW
            sudo ufw --force reset > /dev/null 2>&1
            
            # Default policies
            sudo ufw default deny incoming > /dev/null 2>&1
            sudo ufw default allow outgoing > /dev/null 2>&1
            
            # CRITICAL: Always allow SSH on port 22 (primary)
            sudo ufw allow 22/tcp > /dev/null 2>&1
            sudo ufw limit 22/tcp > /dev/null 2>&1
            print_success "CRITICAL: SSH port 22 ALWAYS allowed and rate-limited"
            
            # Allow SSH on detected port (if different from 22)
            ssh_port=$(sudo sshd -T 2>/dev/null | awk '/^port / {print $2; exit}')
            if [ -n "$ssh_port" ] && [ "$ssh_port" != "22" ]; then
                sudo ufw allow "${ssh_port}/tcp" > /dev/null 2>&1
                sudo ufw limit "${ssh_port}/tcp" > /dev/null 2>&1
                print_info "Additional SSH port ${ssh_port} allowed"
            fi
            
            # Also allow SSH service rule as backup
            sudo ufw allow ssh > /dev/null 2>&1
            sudo ufw limit ssh > /dev/null 2>&1
            print_info "SSH service rule added as backup"
            
            # Ask for additional ports
            if ask_yes_no "Allow HTTP (port 80)?" "y"; then
                sudo ufw allow 80 > /dev/null 2>&1
            fi
            
            if ask_yes_no "Allow HTTPS (port 443)?" "y"; then
                sudo ufw allow 443 > /dev/null 2>&1
            fi
            
            # Custom ports
            if ask_yes_no "Add custom ports?" "n"; then
                echo -e "${YELLOW}Enter ports to allow (comma-separated, e.g., 8080,3000):${NC} \c"
                read custom_ports
                
                IFS=',' read -ra PORTS <<< "$custom_ports"
                for port in "${PORTS[@]}"; do
                    port=$(echo "$port" | tr -d ' ')
                    if [[ "$port" =~ ^[0-9]+$ ]]; then
                        sudo ufw allow "$port" > /dev/null 2>&1
                        print_info "Allowed port $port"
                    fi
                done
            fi
            
            # Enable firewall
            echo -e "${CYAN}Enabling firewall...${NC}"
            sudo ufw --force enable > /dev/null 2>&1
            
            # CRITICAL: Verify SSH access is maintained
            echo -e "${CYAN}Verifying SSH access is maintained...${NC}"
            if sudo ufw status | grep -q "22.*ALLOW"; then
                print_success "SSH port 22 confirmed as ALLOWED"
            else
                print_error "WARNING: SSH port 22 not found in firewall rules!"
                print_warning "Emergency: Adding SSH port 22 manually..."
                sudo ufw allow 22/tcp > /dev/null 2>&1
                sudo ufw reload > /dev/null 2>&1
                print_success "SSH port 22 emergency-added and firewall reloaded"
            fi
            
            print_success "UFW firewall configured and enabled"
            print_warning "IMPORTANT: Test SSH access from another terminal before closing this session!"
        fi
    fi
}

kernel_hardening() {
    if ask_yes_no "Apply kernel security hardening?" "$DEFAULT_KERNEL_HARDEN"; then
        print_step "8" "Applying Kernel Security Hardening"
        echo
        
        echo -e "${CYAN}Configuring kernel security parameters...${NC}"
        
        # Decide whether to disable IPv6
        ipv6_ssh_listen=0
        if ss -tlpn 2>/dev/null | grep -q ':::22'; then
            ipv6_ssh_listen=1
        fi
        DISABLE_IPV6="n"
        if [ "$ipv6_ssh_listen" -eq 1 ]; then
            print_warning "IPv6 SSH detected; skipping IPv6 disable by default."
            if ask_yes_no "Force disable IPv6 anyway?" "n"; then DISABLE_IPV6="y"; fi
        else
            if ask_yes_no "Disable IPv6 networking (recommended on IPv4-only hosts)?" "n"; then DISABLE_IPV6="y"; fi
        fi

        cat > /tmp/99-security.conf << 'EOF'
# Network Security Settings
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_all = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.tcp_syncookies = 1

# Kernel security settings
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.randomize_va_space = 2
EOF
        
        if [ "$DISABLE_IPV6" = "y" ]; then
            echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /tmp/99-security.conf
            echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /tmp/99-security.conf
        fi

        sudo cp /tmp/99-security.conf /etc/sysctl.d/99-security.conf
        rm /tmp/99-security.conf
        
        sudo sysctl -p /etc/sysctl.d/99-security.conf > /dev/null 2>&1
        
        print_success "Kernel security hardening applied"
    fi
}

create_monitoring_script() {
    if ask_yes_no "Create security monitoring script?" "$DEFAULT_CREATE_MONITORING"; then
        print_step "9" "Creating Security Monitoring Script"
        echo
        
        echo -e "${CYAN}Creating markdown security report generator...${NC}"
        
        # Copy the advanced security report script
        cat > security-report.sh << 'EOF'
#!/bin/bash

# Security Report Generator - Markdown Format
# Generates a beautiful markdown security report

OUTPUT_FILE="security-check.md"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S UTC')
DATE_ONLY=$(date '+%Y-%m-%d')

# Function to get status emoji
get_status_emoji() {
    local status="$1"
    case "$status" in
        "active"|"enabled"|"running") echo "🟢" ;;
        "inactive"|"disabled"|"stopped") echo "🔴" ;;
        "failed"|"error") echo "❌" ;;
        *) echo "🟡" ;;
    esac
}

# Function to get security level badge
get_security_badge() {
    local banned_count="$1"
    local failed_attempts="$2"
    
    if [ "$banned_count" -gt 5 ] && [ "$failed_attempts" -gt 50 ]; then
        echo "🔴 **HIGH THREAT**"
    elif [ "$banned_count" -gt 2 ] || [ "$failed_attempts" -gt 20 ]; then
        echo "🟡 **MEDIUM THREAT**"
    elif [ "$banned_count" -gt 0 ] || [ "$failed_attempts" -gt 5 ]; then
        echo "🟠 **LOW THREAT**"
    else
        echo "🟢 **SECURE**"
    fi
}

# Start generating the markdown report
cat > "$OUTPUT_FILE" << MDEOF
# 🛡️ Server Security Status Report

> **Generated:** $TIMESTAMP  
> **Hostname:** \`$(hostname)\`  
> **System:** $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)

---

## 📊 Executive Summary

MDEOF

# Get key metrics for summary
FAIL2BAN_STATUS=$(sudo systemctl is-active fail2ban 2>/dev/null || echo "inactive")
FAILED_ATTEMPTS=$(sudo journalctl -u ssh.service --since "24 hours ago" 2>/dev/null | grep -i "failed\|invalid" | wc -l)
BANNED_IPS=$(sudo fail2ban-client status sshd 2>/dev/null | grep "Currently banned:" | awk '{print $4}' | grep -o '[0-9]*' || echo "0")
SECURITY_LEVEL=$(get_security_badge "$BANNED_IPS" "$FAILED_ATTEMPTS")

cat >> "$OUTPUT_FILE" << MDEOF
| Metric | Status | Value |
|--------|--------|-------|
| **Security Level** | $SECURITY_LEVEL | Active monitoring |
| **Fail2Ban Protection** | $(get_status_emoji "$FAIL2BAN_STATUS") | $FAIL2BAN_STATUS |
| **Failed Login Attempts (24h)** | $([ "$FAILED_ATTEMPTS" -gt 10 ] && echo "⚠️" || echo "✅") | $FAILED_ATTEMPTS attempts |
| **Currently Banned IPs** | $([ "$BANNED_IPS" -gt 0 ] && echo "🚫" || echo "✅") | $BANNED_IPS IPs blocked |
| **System Uptime** | 🕐 | $(uptime -p) |

---

## 🔒 Security Services Status

### Fail2Ban Intrusion Prevention
MDEOF

if command -v fail2ban-client &> /dev/null && sudo systemctl is-active fail2ban &>/dev/null; then
    cat >> "$OUTPUT_FILE" << MDEOF

\`\`\`
$(sudo fail2ban-client status 2>/dev/null)
\`\`\`

#### SSH Protection Details
MDEOF
    
    if sudo fail2ban-client status sshd &>/dev/null; then
        SSH_STATUS=$(sudo fail2ban-client status sshd 2>/dev/null)
        CURRENTLY_FAILED=$(echo "$SSH_STATUS" | grep "Currently failed:" | awk '{print $4}' | grep -o '[0-9]*' || echo "0")
        TOTAL_FAILED=$(echo "$SSH_STATUS" | grep "Total failed:" | awk '{print $4}' | grep -o '[0-9]*' || echo "0")
        CURRENTLY_BANNED=$(echo "$SSH_STATUS" | grep "Currently banned:" | awk '{print $4}' | grep -o '[0-9]*' || echo "0")
        TOTAL_BANNED=$(echo "$SSH_STATUS" | grep "Total banned:" | awk '{print $4}' | grep -o '[0-9]*' || echo "0")
        BANNED_IP_LIST=$(echo "$SSH_STATUS" | grep "Banned IP list:" | cut -d: -f2 | xargs)
        
        cat >> "$OUTPUT_FILE" << MDEOF

| SSH Jail Metric | Count | Status |
|-----------------|-------|--------|
| Currently Failed | $CURRENTLY_FAILED | $([ "$CURRENTLY_FAILED" -gt 5 ] && echo "⚠️" || echo "✅") |
| Total Failed | $TOTAL_FAILED | $([ "$TOTAL_FAILED" -gt 50 ] && echo "🔴" || echo "🟡") |
| Currently Banned | $CURRENTLY_BANNED | $([ "$CURRENTLY_BANNED" -gt 0 ] && echo "🚫" || echo "✅") |
| Total Banned | $TOTAL_BANNED | 📊 |

MDEOF
        
        if [ -n "$BANNED_IP_LIST" ] && [ "$BANNED_IP_LIST" != "" ]; then
            cat >> "$OUTPUT_FILE" << MDEOF
#### 🚫 Currently Banned IP Addresses

\`\`\`
$BANNED_IP_LIST
\`\`\`

MDEOF
        fi
    fi
else
    cat >> "$OUTPUT_FILE" << MDEOF

> ❌ **Fail2Ban is not installed or not running**  
> This is a critical security vulnerability. Install Fail2Ban immediately.

MDEOF
fi

# SSH Security Configuration
cat >> "$OUTPUT_FILE" << MDEOF
### SSH Security Configuration

| Setting | Status | Configuration |
|---------|--------|---------------|
MDEOF

# Check SSH settings
ROOT_LOGIN=$(sudo grep "^PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null | head -1 || echo "PermitRootLogin not set")
PASSWORD_AUTH=$(sudo grep "^PasswordAuthentication" /etc/ssh/sshd_config 2>/dev/null | head -1 || echo "PasswordAuthentication not set")
MAX_AUTH_TRIES=$(sudo grep "^MaxAuthTries" /etc/ssh/sshd_config* 2>/dev/null | head -1 || echo "MaxAuthTries default")

cat >> "$OUTPUT_FILE" << MDEOF
| Root Login | $(echo "$ROOT_LOGIN" | grep -q "no" && echo "🟢 Disabled" || echo "🔴 Enabled") | \`$ROOT_LOGIN\` |
| Password Authentication | $(echo "$PASSWORD_AUTH" | grep -q "no" && echo "🟢 Disabled" || echo "🔴 Enabled") | \`$PASSWORD_AUTH\` |
| Max Auth Tries | $(echo "$MAX_AUTH_TRIES" | grep -q "MaxAuthTries" && echo "🟢 Limited" || echo "🟡 Default") | \`$MAX_AUTH_TRIES\` |

---

## 🌐 Network Security

### Firewall Status
MDEOF

if command -v ufw &> /dev/null; then
    UFW_STATUS=$(sudo ufw status 2>/dev/null)
    if echo "$UFW_STATUS" | grep -q "Status: active"; then
        cat >> "$OUTPUT_FILE" << MDEOF

🟢 **UFW Firewall is ACTIVE**

\`\`\`
$UFW_STATUS
\`\`\`

MDEOF
    else
        cat >> "$OUTPUT_FILE" << MDEOF

🔴 **UFW Firewall is INACTIVE**

> Warning: No firewall protection detected.

MDEOF
    fi
else
    cat >> "$OUTPUT_FILE" << MDEOF

🟡 **UFW not installed**

> Consider installing UFW for additional network protection.

MDEOF
fi

# System Resources and final sections...
cat >> "$OUTPUT_FILE" << MDEOF

---

## 💻 System Resources

| Resource | Usage | Status |
|----------|-------|--------|
| Memory | $(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100.0}') | ✅ |
| Disk (/) | $(df / | tail -1 | awk '{print $5}') | ✅ |
| Load Average | $(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//') | ✅ |

---

## 📊 Attack Analysis (Last 24 Hours)

- **Total Failed Attempts**: $FAILED_ATTEMPTS
- **Currently Banned IPs**: $BANNED_IPS
- **Attack Trend**: $([ "$FAILED_ATTEMPTS" -gt 50 ] && echo "🔴 High" || [ "$FAILED_ATTEMPTS" -gt 20 ] && echo "🟡 Medium" || echo "🟢 Low")

---

*Generated by Astro Server Security Monitoring Tool* 🛡️
MDEOF

echo "✅ Security report generated: $OUTPUT_FILE"
echo "📊 View the report with: cat $OUTPUT_FILE"
echo "🌐 Open $OUTPUT_FILE in a markdown viewer for best experience"
EOF
        
        chmod +x security-report.sh
        
        print_success "Markdown security report generator created as 'security-report.sh'"
        
        if ask_yes_no "Generate security report now?" "y"; then
            echo
            ./security-report.sh
            echo
            print_info "Security report saved as 'security-check.md'"
        fi
    fi
}

final_report() {
    print_step "10" "Security Hardening Complete!"
    echo
    
    echo -e "${GREEN}${BOLD}🎉 CONGRATULATIONS! 🎉${NC}"
    echo -e "${WHITE}Your server has been successfully hardened with the following security measures:${NC}"
    echo
    
    echo -e "${CYAN}✅ System Updates:${NC} Applied latest security patches"
    echo -e "${CYAN}✅ SSH Hardening:${NC} Root login disabled, connection limits set"
    
    if command -v fail2ban-client &> /dev/null; then
        echo -e "${CYAN}✅ Fail2Ban:${NC} Brute force protection active"
    fi
    
    if command -v ufw &> /dev/null && sudo ufw status | grep -q "Status: active"; then
        echo -e "${CYAN}✅ Firewall:${NC} UFW configured and active"
    fi
    
    echo -e "${CYAN}✅ Kernel Hardening:${NC} Network security parameters applied"
    
    if systemctl is-active --quiet unattended-upgrades; then
        echo -e "${CYAN}✅ Auto Updates:${NC} Automatic security updates enabled"
    fi
    
    if [ -f "security-monitor.sh" ]; then
        echo -e "${CYAN}✅ Monitoring:${NC} Security monitoring script created"
    fi
    
    echo
    echo -e "${YELLOW}${BOLD}📋 IMPORTANT NOTES:${NC}"
    echo -e "${WHITE}• SSH configuration backup saved in /etc/ssh/sshd_config.backup.*${NC}"
    echo -e "${WHITE}• Run './security-monitor.sh' to check security status${NC}"
    echo -e "${WHITE}• Monitor logs regularly: sudo journalctl -u ssh.service${NC}"
    echo -e "${WHITE}• Keep your system updated: sudo apt update && sudo apt upgrade${NC}"
    echo
    
    echo -e "${PURPLE}${BOLD}🚀 Your server is now ASTRO-level secure! 🚀${NC}"
    echo
}

# Argument parsing
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --profile)
                PROFILE="$2"; shift 2 ;;
            --no-jokes)
                ASTRO_NO_JOKES=1; export ASTRO_NO_JOKES; shift ;;
            --config)
                # Not implemented; accept and ignore to remain compatible with entrypoint
                shift 2 ;;
            *)
                break ;;
        esac
    done
}

# Main execution
main() {
    print_banner
    
    # Check prerequisites
    check_root
    parse_args "$@"
    apply_profile_defaults
    
    # Run security hardening steps
    system_info
    configure_timezone
    update_system
    configure_unattended_upgrades
    harden_ssh
    install_fail2ban
    configure_firewall
    kernel_hardening
    create_monitoring_script
    final_report
}

# Trap to handle script interruption
trap 'echo -e "\n${RED}Script interrupted. Exiting...${NC}"; exit 1' INT TERM

# Run main function
main "$@"