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
cat > "$OUTPUT_FILE" << EOF
# 🛡️ Server Security Status Report

> **Generated:** $TIMESTAMP  
> **Hostname:** \`$(hostname)\`  
> **System:** $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)

---

## 📊 Executive Summary

EOF

# Get key metrics for summary
FAIL2BAN_STATUS=$(sudo systemctl is-active fail2ban 2>/dev/null || echo "inactive")
FAILED_ATTEMPTS=$(sudo journalctl -u ssh.service --since "24 hours ago" 2>/dev/null | grep -i "failed\|invalid" | wc -l)
FAILED_ATTEMPTS=${FAILED_ATTEMPTS:-0}

BANNED_IPS=$(sudo fail2ban-client status sshd 2>/dev/null | grep "Currently banned:" | awk '{print $4}' | grep -o '[0-9]*')
BANNED_IPS=${BANNED_IPS:-0}

SECURITY_LEVEL=$(get_security_badge "$BANNED_IPS" "$FAILED_ATTEMPTS")

cat >> "$OUTPUT_FILE" << EOF
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
EOF

if command -v fail2ban-client &> /dev/null && sudo systemctl is-active fail2ban &>/dev/null; then
    cat >> "$OUTPUT_FILE" << EOF

\`\`\`
$(sudo fail2ban-client status 2>/dev/null)
\`\`\`

#### SSH Protection Details
EOF
    
    if sudo fail2ban-client status sshd &>/dev/null; then
        SSH_STATUS=$(sudo fail2ban-client status sshd 2>/dev/null)
        CURRENTLY_FAILED=$(echo "$SSH_STATUS" | grep "Currently failed:" | awk '{print $4}' | grep -o '[0-9]*')
        CURRENTLY_FAILED=${CURRENTLY_FAILED:-0}

        TOTAL_FAILED=$(echo "$SSH_STATUS" | grep "Total failed:" | awk '{print $4}' | grep -o '[0-9]*')
        TOTAL_FAILED=${TOTAL_FAILED:-0}

        CURRENTLY_BANNED=$(echo "$SSH_STATUS" | grep "Currently banned:" | awk '{print $4}' | grep -o '[0-9]*')
        CURRENTLY_BANNED=${CURRENTLY_BANNED:-0}

        TOTAL_BANNED=$(echo "$SSH_STATUS" | grep "Total banned:" | awk '{print $4}' | grep -o '[0-9]*')
        TOTAL_BANNED=${TOTAL_BANNED:-0}

        BANNED_IP_LIST=$(echo "$SSH_STATUS" | grep "Banned IP list:" | cut -d: -f2 | xargs)
        
        cat >> "$OUTPUT_FILE" << EOF

| SSH Jail Metric | Count | Status |
|-----------------|-------|--------|
| Currently Failed | $CURRENTLY_FAILED | $([ "$CURRENTLY_FAILED" -gt 5 ] && echo "⚠️" || echo "✅") |
| Total Failed | $TOTAL_FAILED | $([ "$TOTAL_FAILED" -gt 50 ] && echo "🔴" || echo "🟡") |
| Currently Banned | $CURRENTLY_BANNED | $([ "$CURRENTLY_BANNED" -gt 0 ] && echo "🚫" || echo "✅") |
| Total Banned | $TOTAL_BANNED | 📊 |

EOF
        
        if [ -n "$BANNED_IP_LIST" ]; then
            cat >> "$OUTPUT_FILE" << EOF
#### 🚫 Currently Banned IP Addresses

\`\`\`
$BANNED_IP_LIST
\`\`\`

EOF
        fi
    fi
else
    cat >> "$OUTPUT_FILE" << EOF

> ❌ **Fail2Ban is not installed or not running**  
> This is a critical security vulnerability. Install Fail2Ban immediately.

EOF
fi

# SSH Security Configuration
cat >> "$OUTPUT_FILE" << EOF
### SSH Security Configuration

| Setting | Status | Configuration |
|---------|--------|---------------|
EOF

# Check SSH settings
ROOT_LOGIN=$(sudo grep "^PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null | head -1 || echo "PermitRootLogin not set")
PASSWORD_AUTH=$(sudo grep "^PasswordAuthentication" /etc/ssh/sshd_config 2>/dev/null | head -1 || echo "PasswordAuthentication not set")
MAX_AUTH_TRIES=$(sudo grep "^MaxAuthTries" /etc/ssh/sshd_config* 2>/dev/null | head -1 || echo "MaxAuthTries default")

cat >> "$OUTPUT_FILE" << EOF
| Root Login | $(echo "$ROOT_LOGIN" | grep -q "no" && echo "🟢 Disabled" || echo "🔴 Enabled") | \`$ROOT_LOGIN\` |
| Password Authentication | $(echo "$PASSWORD_AUTH" | grep -q "no" && echo "🟢 Disabled" || echo "🔴 Enabled") | \`$PASSWORD_AUTH\` |
| Max Auth Tries | $(echo "$MAX_AUTH_TRIES" | grep -q "MaxAuthTries" && echo "🟢 Limited" || echo "🟡 Default") | \`$MAX_AUTH_TRIES\` |

---

## 🌐 Network Security

### Firewall Status
EOF

if command -v ufw &> /dev/null; then
    UFW_STATUS=$(sudo ufw status 2>/dev/null)
    if echo "$UFW_STATUS" | grep -q "Status: active"; then
        cat >> "$OUTPUT_FILE" << EOF

🟢 **UFW Firewall is ACTIVE**

\`\`\`
$UFW_STATUS
\`\`\`

EOF
    else
        cat >> "$OUTPUT_FILE" << EOF

🔴 **UFW Firewall is INACTIVE**

> Warning: No firewall protection detected.

EOF
    fi
else
    cat >> "$OUTPUT_FILE" << EOF

🟡 **UFW not installed**

> Consider installing UFW for additional network protection.

EOF
fi

# Network connections
cat >> "$OUTPUT_FILE" << EOF
### Active Network Services

| Port | Protocol | Service | Status |
|------|----------|---------|--------|
EOF

sudo ss -tuln 2>/dev/null | grep LISTEN | while read line; do
    PROTO=$(echo "$line" | awk '{print $1}')
    ADDRESS=$(echo "$line" | awk '{print $5}')
    PORT=$(echo "$ADDRESS" | grep -o ':[0-9]*$' | cut -d: -f2)
    
    case "$PORT" in
        22) SERVICE="SSH" ;;
        80) SERVICE="HTTP" ;;
        443) SERVICE="HTTPS" ;;
        53) SERVICE="DNS" ;;
        *) SERVICE="Unknown" ;;
    esac
    
    STATUS_ICON="🟢"
    [ "$PORT" = "22" ] && STATUS_ICON="🔐"
    [ "$SERVICE" = "Unknown" ] && STATUS_ICON="🟡"
    
    echo "| $PORT | $PROTO | $SERVICE | $STATUS_ICON |" >> "$OUTPUT_FILE"
done

# System Resources
cat >> "$OUTPUT_FILE" << EOF

---

## 💻 System Resources

### Resource Usage
EOF

MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')

cat >> "$OUTPUT_FILE" << EOF

| Resource | Usage | Status |
|----------|-------|--------|
| Memory | ${MEMORY_USAGE}% | $([ "${MEMORY_USAGE%.*}" -gt 80 ] && echo "⚠️" || echo "✅") |
| Disk (/) | ${DISK_USAGE}% | $([ "$DISK_USAGE" -gt 80 ] && echo "⚠️" || echo "✅") |
| Load Average | $LOAD_AVG | $(awk "BEGIN {print ($LOAD_AVG > 2.0) ? \"⚠️\" : \"✅\"}") |

### Detailed Resource Information

\`\`\`
$(free -h)
\`\`\`

\`\`\`
$(df -h /)
\`\`\`

---

## 🔄 Security Updates

### Automatic Updates Status
EOF

UNATTENDED_STATUS=$(sudo systemctl is-active unattended-upgrades 2>/dev/null || echo "inactive")
cat >> "$OUTPUT_FILE" << EOF

| Service | Status | Configuration |
|---------|--------|---------------|
| Unattended Upgrades | $(get_status_emoji "$UNATTENDED_STATUS") $UNATTENDED_STATUS | $([ "$UNATTENDED_STATUS" = "active" ] && echo "✅ Enabled" || echo "❌ Disabled") |

### Recent Security Updates
EOF

if [ -f /var/log/apt/history.log ]; then
    RECENT_UPDATES=$(grep "$DATE_ONLY" /var/log/apt/history.log 2>/dev/null | tail -3)
    if [ -n "$RECENT_UPDATES" ]; then
        cat >> "$OUTPUT_FILE" << EOF

\`\`\`
$RECENT_UPDATES
\`\`\`
EOF
    else
        cat >> "$OUTPUT_FILE" << EOF

> No security updates found for today ($DATE_ONLY)
EOF
    fi
else
    cat >> "$OUTPUT_FILE" << EOF

> Update log not available
EOF
fi

# Security Recommendations
cat >> "$OUTPUT_FILE" << EOF

---

## 📋 Security Recommendations

### Immediate Actions Required
EOF

RECOMMENDATIONS=""

# Check for critical issues
if [ "$FAIL2BAN_STATUS" != "active" ]; then
    RECOMMENDATIONS="${RECOMMENDATIONS}- 🔴 **CRITICAL**: Install and configure Fail2Ban\n"
fi

if echo "$ROOT_LOGIN" | grep -q "yes"; then
    RECOMMENDATIONS="${RECOMMENDATIONS}- 🔴 **CRITICAL**: Disable SSH root login\n"
fi

if echo "$PASSWORD_AUTH" | grep -q "yes"; then
    RECOMMENDATIONS="${RECOMMENDATIONS}- 🟡 **WARNING**: Consider disabling SSH password authentication\n"
fi

if [ "$UNATTENDED_STATUS" != "active" ]; then
    RECOMMENDATIONS="${RECOMMENDATIONS}- 🟡 **WARNING**: Enable automatic security updates\n"
fi

if ! command -v ufw &> /dev/null; then
    RECOMMENDATIONS="${RECOMMENDATIONS}- 🟡 **SUGGESTION**: Consider installing UFW firewall\n"
fi

if [ -n "$RECOMMENDATIONS" ]; then
    echo -e "$RECOMMENDATIONS" >> "$OUTPUT_FILE"
else
    cat >> "$OUTPUT_FILE" << EOF
✅ **No critical security issues detected**

Your server appears to be well-configured from a security perspective.
EOF
fi

cat >> "$OUTPUT_FILE" << EOF

### Best Practices Checklist

- [ ] Regular security updates applied
- [ ] SSH key-based authentication configured
- [ ] Fail2Ban monitoring active attacks
- [ ] Firewall rules properly configured
- [ ] System logs monitored regularly
- [ ] Backup strategy implemented
- [ ] Security monitoring automated

---

## 📊 Attack Analysis (Last 24 Hours)

EOF

# Analyze recent attacks
if [ "$FAILED_ATTEMPTS" -gt 0 ]; then
    cat >> "$OUTPUT_FILE" << EOF
### Attack Summary

- **Total Failed Attempts**: $FAILED_ATTEMPTS
- **Currently Banned IPs**: $BANNED_IPS
- **Attack Trend**: $([ "$FAILED_ATTEMPTS" -gt 50 ] && echo "🔴 High" || [ "$FAILED_ATTEMPTS" -gt 20 ] && echo "🟡 Medium" || echo "🟢 Low")

### Recent Attack Patterns

\`\`\`
$(sudo journalctl -u ssh.service --since "24 hours ago" 2>/dev/null | grep -i "failed\|invalid" | tail -10 | awk '{print $1, $2, $3, $NF}' | sort | uniq -c | sort -nr)
\`\`\`
EOF
else
    cat >> "$OUTPUT_FILE" << EOF
### Attack Summary

✅ **No failed login attempts detected in the last 24 hours**

Your server appears to be secure and not under active attack.
EOF
fi

# Footer
cat >> "$OUTPUT_FILE" << EOF

---

## 🔧 Generated Information

- **Report Generated**: $TIMESTAMP
- **Report Type**: Automated Security Assessment
- **Script Version**: 1.0
- **Next Recommended Check**: $(date -d '+1 day' '+%Y-%m-%d %H:%M:%S')

> 💡 **Tip**: Run this security check daily to monitor your server's security posture.  
> 🚀 **Automation**: Consider adding this to a daily cron job for continuous monitoring.

---

*Generated by Astro Server Security Monitoring Tool* 🛡️
EOF

echo "✅ Security report generated: $OUTPUT_FILE"
echo "📊 View the report: cat $OUTPUT_FILE"
echo "🌐 For better viewing, open $OUTPUT_FILE in a markdown viewer"
